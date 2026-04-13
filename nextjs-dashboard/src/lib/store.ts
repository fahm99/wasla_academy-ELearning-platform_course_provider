import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { User } from '@/types';

interface AuthState {
  user: User | null;
  session: any | null;
  isLoading: boolean;
  setUser: (user: User | null) => void;
  setSession: (session: any | null) => void;
  setLoading: (isLoading: boolean) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      session: null,
      isLoading: true,
      setUser: (user) => set({ user }),
      setSession: (session) => set({ session }),
      setLoading: (isLoading) => set({ isLoading }),
      logout: () => set({ user: null, session: null }),
    }),
    {
      name: 'auth-storage',
    }
  )
);

// UI State
interface UIState {
  sidebarOpen: boolean;
  toggleSidebar: () => void;
  setSidebarOpen: (open: boolean) => void;
}

export const useUIStore = create<UIState>()(
  persist(
    (set) => ({
      sidebarOpen: false,
      toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
      setSidebarOpen: (open) => set({ sidebarOpen: open }),
    }),
    {
      name: 'ui-storage',
    }
  )
);

// Course Editor State (temporary form state)
interface CourseEditorState {
  title: string;
  description: string;
  category: string;
  level: string;
  price: number;
  durationHours: number;
  coverImageUrl: string;
  setField: (field: string, value: any) => void;
  reset: () => void;
}
const initialCourseState = {
  title: '',
  description: '',
  category: '',
  level: 'beginner',
  price: 0,
  durationHours: 0,
  coverImageUrl: '',
};

export const useCourseEditorStore = create<CourseEditorState>()(
  persist(
    (set) => ({
      ...initialCourseState,
      setField: (field, value) => set((state) => ({ ...state, [field]: value })),
      reset: () => set(initialCourseState),
    }),
    {
      name: 'course-editor-storage',
    }
  )
);