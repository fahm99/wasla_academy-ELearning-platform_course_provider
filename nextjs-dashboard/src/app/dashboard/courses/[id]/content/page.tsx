'use client';

import { useState, useEffect, useRef } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { createClient } from '@supabase/supabase-js';
import type { Module, Lesson } from '@/types';
import { VideoUploader, DocumentUploader } from '@/components/ui/FileUploader';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

// ==================== DRAG & DROP TYPES ====================
interface DragItem {
  id: string;
  type: 'lesson' | 'module';
  index: number;
  moduleId?: string;
}

// ==================== VIDEO DURATION EXTRACTOR ====================
const extractVideoDuration = (videoUrl: string): Promise<number> => {
  return new Promise((resolve) => {
    const video = document.createElement('video');
    video.preload = 'metadata';
    video.src = videoUrl;
    
    video.onloadedmetadata = () => {
      resolve(Math.round(video.duration));
      URL.revokeObjectURL(video.src);
    };
    
    video.onerror = () => resolve(0);
    setTimeout(() => resolve(0), 5000);
  });
};

export default function ContentPage() {
  const router = useRouter();
  const params = useParams();
  const courseId = params.id as string;
  
  // ==================== STATE ====================
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [modules, setModules] = useState<Module[]>([]);
  const [lessons, setLessons] = useState<Record<string, Lesson[]>>({});
  const [showModuleDialog, setShowModuleDialog] = useState(false);
  const [showLessonDialog, setShowLessonDialog] = useState(false);
  const [selectedModule, setSelectedModule] = useState<Module | null>(null);
  const [newModuleTitle, setNewModuleTitle] = useState('');
  
  // ==================== DRAG & DROP STATE ====================
  const [draggedItem, setDraggedItem] = useState<DragItem | null>(null);
  const [dragOverItem, setDragOverItem] = useState<DragItem | null>(null);

  const [newLesson, setNewLesson] = useState({
    title: '',
    description: '',
    type: 'video' as 'video' | 'file' | 'text',
    content: '',
    videoUrl: '',
    fileUrl: '',
    duration: 0,
  });

  // ==================== PARALLEL UPLOAD ====================
  const uploadFileParallel = async (
    file: File,
    bucket: string,
    onProgress?: (progress: number) => void
  ): Promise<string> => {
    const chunkSize = 6 * 1024 * 1024; // 6MB chunks
    
    try {
      if (file.size < chunkSize) {
        // Direct upload for small files
        const fileName = `${courseId}/${Date.now()}-${file.name}`;
        const { data, error } = await supabase.storage
          .from(bucket)
          .upload(fileName, file, { cacheControl: '3600', upsert: false });

        if (error) throw error;
        const { data: urlData } = supabase.storage.from(bucket).getPublicUrl(data.path);
        return urlData.publicUrl;
      }

      // Chunked parallel upload for large files
      const fileName = `${courseId}/${Date.now()}-${file.name}`;
      const totalChunks = Math.ceil(file.size / chunkSize);
      const uploadPromises: Promise<any>[] = [];

      for (let i = 0; i < totalChunks; i++) {
        const start = i * chunkSize;
        const end = Math.min(start + chunkSize, file.size);
        const chunk = file.slice(start, end);
        
        const promise = supabase.storage
          .from(bucket)
          .upload(`${fileName}.part${i}`, chunk, { cacheControl: '3600', upsert: true })
          .then(() => {
            if (onProgress) {
              onProgress(Math.round(((i + 1) / totalChunks) * 100));
            }
          });
        
        uploadPromises.push(promise);
      }

      // Upload 4 chunks in parallel
      for (let i = 0; i < uploadPromises.length; i += 4) {
        await Promise.all(uploadPromises.slice(i, i + 4));
      }

      const { data: urlData } = supabase.storage.from(bucket).getPublicUrl(fileName);
      return urlData.publicUrl;
    } catch (error) {
      console.error('Upload error:', error);
      throw error;
    }
  };

  // ==================== FETCH DATA (Parallel) ====================
  useEffect(() => {
    async function fetchData() {
      if (!courseId) return;

      const { data: modulesData } = await supabase
        .from('modules')
        .select('*')
        .eq('course_id', courseId)
        .order('order_index');
    
      if (modulesData) {
        setModules(modulesData as Module[]);
        
        // Fetch all lessons in parallel
        const lessonPromises = modulesData.map(async (module) => {
          const { data } = await supabase
            .from('lessons')
            .select('*')
            .eq('module_id', module.id)
            .order('order_index');
          return { moduleId: module.id, lessons: data as Lesson[] || [] };
        });

        const results = await Promise.all(lessonPromises);
        const lessonsMap: Record<string, Lesson[]> = {};
        results.forEach(({ moduleId, lessons: moduleLessons }) => {
          lessonsMap[moduleId] = moduleLessons;
        });
        setLessons(lessonsMap);
      }
      setLoading(false);
    }
    fetchData();
  }, [courseId]);

  // ==================== DRAG & DROP HANDLERS ====================
  const handleDragStart = (e: React.DragEvent, item: DragItem) => {
    setDraggedItem(item);
    e.dataTransfer.effectAllowed = 'move';
  };

  const handleDragOver = (e: React.DragEvent, item: DragItem) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    setDragOverItem(item);
  };

  const handleDragLeave = () => setDragOverItem(null);

  const handleDrop = async (e: React.DragEvent, targetItem: DragItem) => {
    e.preventDefault();
    if (!draggedItem || draggedItem.id === targetItem.id) {
      setDraggedItem(null);
      setDragOverItem(null);
      return;
    }

    setSaving(true);
    try {
      if (draggedItem.type === 'lesson' && targetItem.type === 'lesson') {
        const sourceModuleId = draggedItem.moduleId!;
        const targetModuleId = targetItem.moduleId!;
        const sourceLessons = [...(lessons[sourceModuleId] || [])];
        const [movedLesson] = sourceLessons.splice(draggedItem.index, 1);
        
        if (sourceModuleId === targetModuleId) {
          sourceLessons.splice(targetItem.index, 0, movedLesson);
          for (let i = 0; i < sourceLessons.length; i++) {
            await supabase.from('lessons').update({ order_index: i }).eq('id', sourceLessons[i].id);
          }
          setLessons({ ...lessons, [sourceModuleId]: sourceLessons });
        } else {
          const targetLessons = [...(lessons[targetModuleId] || [])];
          await supabase.from('lessons').update({ module_id: targetModuleId }).eq('id', movedLesson.id);
          targetLessons.splice(targetItem.index, 0, { ...movedLesson, module_id: targetModuleId });
          
          for (let i = 0; i < sourceLessons.length; i++) {
            await supabase.from('lessons').update({ order_index: i }).eq('id', sourceLessons[i].id);
          }
          for (let i = 0; i < targetLessons.length; i++) {
            await supabase.from('lessons').update({ order_index: i }).eq('id', targetLessons[i].id);
          }
          setLessons({ ...lessons, [sourceModuleId]: sourceLessons, [targetModuleId]: targetLessons });
        }
      } else if (draggedItem.type === 'module' && targetItem.type === 'module') {
        const [movedModule] = modules.splice(draggedItem.index, 1);
        modules.splice(targetItem.index, 0, movedModule);
        for (let i = 0; i < modules.length; i++) {
          await supabase.from('modules').update({ order_index: i }).eq('id', modules[i].id);
        }
        setModules([...modules]);
      }
    } finally {
      setSaving(false);
      setDraggedItem(null);
      setDragOverItem(null);
    }
  };

  const handleModuleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
  };

  // ==================== ADD MODULE ====================
  const handleAddModule = async () => {
    if (!newModuleTitle.trim()) return;

    const { data, error } = await supabase
      .from('modules')
      .insert({
        course_id: courseId,
        title: newModuleTitle,
        order_index: modules.length,
      })
      .select()
      .single();

    if (!error && data) {
      setModules([...modules, data as Module]);
      setLessons(prev => ({ ...prev, [data.id]: [] }));
      setNewModuleTitle('');
      setShowModuleDialog(false);
    }
  };

  const handleDeleteModule = async (moduleId: string) => {
    if (!confirm('هل أنت متأكد من حذف هذه الوحدة؟')) return;

    setSaving(true);
    try {
      await supabase.from('modules').delete().eq('id', moduleId);
      setModules(modules.filter(m => m.id !== moduleId));
      const newLessons = { ...lessons };
      delete newLessons[moduleId];
      setLessons(newLessons);
    } finally {
      setSaving(false);
    }
  };

  // ==================== ADD LESSON ====================
  const handleAddLesson = async () => {
    if (!selectedModule || !newLesson.title.trim()) return;

    const moduleLessons = lessons[selectedModule.id] || [];
    const lessonData = {
      module_id: selectedModule.id,
      course_id: courseId,
      title: newLesson.title,
      description: newLesson.description,
      type: newLesson.type,
      content: newLesson.type === 'text' ? newLesson.content : undefined,
      video_url: newLesson.type === 'video' ? newLesson.videoUrl : undefined,
      file_url: newLesson.type === 'file' ? newLesson.fileUrl : undefined,
      duration: newLesson.duration,
      order_index: moduleLessons.length,
    };

    setSaving(true);
    const { data, error } = await supabase
      .from('lessons')
      .insert(lessonData)
      .select()
      .single();

    if (!error && data) {
      setLessons({
        ...lessons,
        [selectedModule.id]: [...moduleLessons, data as Lesson],
      });
      setNewLesson({
        title: '',
        description: '',
        type: 'video',
        content: '',
        videoUrl: '',
        fileUrl: '',
        duration: 0,
      });
      setShowLessonDialog(false);
    }
    setSaving(false);
  };

  // ==================== VIDEO UPLOAD WITH AUTO-DURATION ====================
  const handleVideoUploadComplete = async (url: string) => {
    // Extract duration automatically
    const duration = await extractVideoDuration(url);
    setNewLesson({ ...newLesson, videoUrl: url, duration });
    
    // Auto-generate title from filename if empty
    if (!newLesson.title) {
      const fileName = url.split('/').pop()?.split('-').slice(1).join(' ') || 'فيديو';
      setNewLesson(prev => ({ ...prev, title: fileName }));
    }
  };

  const handleFileUploadComplete = (url: string) => {
    setNewLesson({ ...newLesson, fileUrl: url });
    // Auto-generate title from filename
    if (!newLesson.title) {
      const fileName = url.split('/').pop() || 'ملف';
      setNewLesson(prev => ({ ...prev, title: fileName.replace(/\.[^/.]+$/, '') }));
    }
  };

  const handleDeleteLesson = async (moduleId: string, lessonId: string) => {
    if (!confirm('هل أنت متأكد من حذف هذا الدرس؟')) return;

    setSaving(true);
    try {
      await supabase.from('lessons').delete().eq('id', lessonId);
      setLessons({
        ...lessons,
        [moduleId]: lessons[moduleId].filter(l => l.id !== lessonId),
      });
    } finally {
      setSaving(false);
    }
  };

  // ==================== TOGGLE FREE ====================
  const handleToggleFree = async (lesson: Lesson) => {
    await supabase
      .from('lessons')
      .update({ is_free: !lesson.is_free })
      .eq('id', lesson.id);
    
    const newLessons = { ...lessons };
    for (const moduleId in newLessons) {
      newLessons[moduleId] = newLessons[moduleId].map(l =>
        l.id === lesson.id ? { ...l, is_free: !l.is_free } : l
      );
    }
    setLessons(newLessons);
  };

  // ==================== FORMAT DURATION ====================
  const formatDuration = (seconds: number): string => {
    if (!seconds) return '--:--';
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  // ==================== RENDER ====================
  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="loading-spinner w-10 h-10"></div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto px-4 py-8">
      {/* Header */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-2xl font-bold text-primary">إدارة المحتوى</h1>
          <p className="text-on-surface-variant mt-1">قم بإضافة الوحدات والدروس - اسحب وأفلت لإعادة الترتيب</p>
        </div>
        <button onClick={() => setShowModuleDialog(true)} className="btn-primary">
          + إضافة وحدة
        </button>
      </div>

      {/* Add Module Dialog */}
      {showModuleDialog && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="card p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4">إضافة وحدة جديدة</h3>
            <input
              type="text"
              value={newModuleTitle}
              onChange={(e) => setNewModuleTitle(e.target.value)}
              placeholder="اسم الوحدة"
              className="input mb-4"
              autoFocus
            />
            <div className="flex gap-3 justify-end">
              <button onClick={() => setShowModuleDialog(false)} className="btn-secondary">
                إلغاء
              </button>
              <button onClick={handleAddModule} disabled={saving} className="btn-primary">
                {saving ? '...' : 'إضافة'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Add Lesson Dialog */}
      {showLessonDialog && selectedModule && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 overflow-y-auto py-8">
          <div className="card p-6 w-full max-w-2xl mx-4">
            <h3 className="text-lg font-bold mb-4">إضافة درس لـ: {selectedModule.title}</h3>
            
            <div className="space-y-4">
              <div>
                <label className="label">نوع المحتوى</label>
                <div className="flex gap-2 flex-wrap">
                  {(['video', 'file', 'text'] as const).map((type) => (
                    <button
                      key={type}
                      onClick={() => setNewLesson({ ...newLesson, type })}
                      className={`btn-sm ${newLesson.type === type ? 'btn-primary' : 'btn-secondary'}`}
                    >
                      {type === 'video' ? '🎬 فيديو' : type === 'file' ? '📄 ملف' : '📝 نص'}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="label">عنوان الدرس</label>
                <input
                  type="text"
                  value={newLesson.title}
                  onChange={(e) => setNewLesson({ ...newLesson, title: e.target.value })}
                  placeholder="أدخل عنوان الدرس (سيتم التعليق تلقائياً من الفيديو)"
                  className="input"
                />
              </div>

              {newLesson.type === 'video' && (
                <div>
                  <label className="label">رفع فيديو (رفع متوازي)</label>
                  <VideoUploader
                    folder={`courses/${courseId}`}
                    onUploadComplete={handleVideoUploadComplete}
                    onError={(err) => console.error(err)}
                  />
                  {newLesson.duration > 0 && (
                    <p className="text-sm text-green-600 mt-2 flex items-center gap-2">
                      ✓ تم استخراج المدة: {formatDuration(newLesson.duration)}
                    </p>
                  )}
                </div>
              )}

              {newLesson.type === 'file' && (
                <div>
                  <label className="label">رفع ملف (PDF, DOC, etc)</label>
                  <DocumentUploader
                    folder={`courses/${courseId}`}
                    onUploadComplete={handleFileUploadComplete}
                    onError={(err) => console.error(err)}
                  />
                </div>
              )}

              {newLesson.type === 'text' && (
                <div>
                  <label className="label">المحتوى النصي</label>
                  <textarea
                    value={newLesson.content}
                    onChange={(e) => setNewLesson({ ...newLesson, content: e.target.value })}
                    placeholder="أدخل محتوى الدرس..."
                    className="input min-h-[200px]"
                  />
                </div>
              )}
            </div>

            <div className="flex gap-3 justify-end mt-6">
              <button onClick={() => setShowLessonDialog(false)} className="btn-secondary">
                إلغاء
              </button>
              <button onClick={handleAddLesson} disabled={saving} className="btn-primary">
                {saving ? '...جاري الحفظ' : 'إضافة الدرس'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modules List */}
      <div className="space-y-6">
        {modules.length === 0 ? (
          <div className="empty-state">
            <div className="empty-state-icon">📚</div>
            <h3 className="text-lg font-medium">لا توجد وحدات</h3>
            <p className="text-on-surface-variant mt-1">أضف أول وحدة لكورس جديد</p>
            <button onClick={() => setShowModuleDialog(true)} className="btn-primary mt-4">
              + إضافة وحدة
            </button>
          </div>
        ) : (
          modules.map((module, moduleIndex) => (
            <div
              key={module.id}
              className={`card transition-all ${
                dragOverItem?.id === module.id && dragOverItem?.type === 'module'
                  ? 'ring-2 ring-secondary shadow-elevated'
                  : ''
              }`}
              onDragOver={handleModuleDragOver}
              onDrop={(e) => handleDrop(e, { id: module.id, type: 'module', index: moduleIndex })}
            >
              {/* Module Header - Draggable */}
              <div 
                className="card-padding flex items-center justify-between border-b border-surface-low cursor-move"
                draggable
                onDragStart={(e) => handleDragStart(e, { id: module.id, type: 'module', index: moduleIndex })}
              >
                <div className="flex items-center gap-3">
                  <span className="text-2xl text-on-surface-subtle">⋮⋮</span>
                  <div>
                    <span className="label-sm text-on-surface-subtle">الوحدة {moduleIndex + 1}</span>
                    <h3 className="font-semibold text-lg">{module.title}</h3>
                    <p className="text-sm text-on-surface-variant">
                      {(lessons[module.id] || []).length} دروس
                    </p>
                  </div>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => { setSelectedModule(module); setShowLessonDialog(true); }}
                    className="btn-sm btn-secondary"
                  >
                    + إضافة درس
                  </button>
                  <button onClick={() => handleDeleteModule(module.id)} className="btn-sm btn-danger">
                    🗑
                  </button>
                </div>
              </div>

              {/* Lessons List */}
              <div className="p-4 space-y-2">
                {(lessons[module.id] || []).length === 0 ? (
                  <p className="text-center text-on-surface-subtle py-8">لا توجد دروس في هذه الوحدة</p>
                ) : (
                  (lessons[module.id] || []).map((lesson, lessonIndex) => (
                    <div
                      key={lesson.id}
                      className={`flex items-center gap-3 p-4 rounded-xl bg-surface-low transition-all ${
                        draggedItem?.id === lesson.id ? 'opacity-50 scale-95' : ''
                      } ${
                        dragOverItem?.id === lesson.id && dragOverItem?.type === 'lesson'
                          ? 'ring-2 ring-secondary shadow-elevated'
                          : 'hover:shadow-float'
                      }`}
                      draggable
                      onDragStart={(e) => handleDragStart(e, {
                        id: lesson.id,
                        type: 'lesson',
                        index: lessonIndex,
                        moduleId: module.id,
                      })}
                      onDragOver={(e) => handleDragOver(e, {
                        id: lesson.id,
                        type: 'lesson',
                        index: lessonIndex,
                        moduleId: module.id,
                      })}
                      onDragLeave={handleDragLeave}
                      onDrop={(e) => handleDrop(e, {
                        id: lesson.id,
                        type: 'lesson',
                        index: lessonIndex,
                        moduleId: module.id,
                      })}
                    >
                      {/* Drag Handle */}
                      <span className="cursor-move text-xl text-on-surface-subtle">⋮⋮</span>
                      
                      {/* Type Icon */}
                      <span className="text-2xl">
                        {lesson.type === 'video' ? '🎬' : lesson.type === 'file' ? '📄' : '📝'}
                      </span>
                      
                      {/* Lesson Info */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 flex-wrap">
                          <span className="font-medium truncate">{lesson.title}</span>
                          {lesson.is_free && <span className="badge-warning">مجاني</span>}
                        </div>
                        {(lesson.duration || 0) > 0 && (
                          <span className="text-sm text-on-surface-subtle">
                            ⏱ {formatDuration(lesson.duration || 0)}
                          </span>
                        )}
                      </div>

                      {/* Actions */}
                      <div className="flex gap-2">
                        <button
                          onClick={() => handleToggleFree(lesson)}
                          className={`btn-sm ${lesson.is_free ? 'btn-gold' : 'btn-secondary'}`}
                        >
                          {lesson.is_free ? '💰' : '💵'}
                        </button>
                        <button
                          onClick={() => handleDeleteLesson(module.id, lesson.id)}
                          className="btn-sm btn-danger"
                        >
                          🗑
                        </button>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          ))
        )}
      </div>

      {/* Saving Indicator */}
      {saving && (
        <div className="fixed bottom-6 left-6 bg-primary text-white px-4 py-3 rounded-xl shadow-elevated flex items-center gap-3">
          <span className="loading-spinner w-4 h-4"></span>
          جاري الحفظ...
        </div>
      )}
    </div>
  );
}