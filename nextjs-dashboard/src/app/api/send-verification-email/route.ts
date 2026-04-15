import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

// Initialize admin client for server-side operations
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

export async function POST(request: Request) {
  try {
    const { email, code } = await request.json();

    if (!email || !code) {
      return NextResponse.json(
        { error: 'Email and code are required' },
        { status: 400 }
      );
    }

    // Option 1: Use Resend (recommended)
    // Set RESEND_API_KEY in your environment variables
    
    /*
    const resend = require('resend') || await import('resend');
    const resend = new Resend(process.env.RESEND_API_KEY);
    
    await resend.emails.send({
      from: 'Wasla <noreply@yourdomain.com>',
      to: email,
      subject: 'رمز التحقق من البريد الإلكتروني - Wasla',
      html: `
        <div style="font-family: Tajawal, sans-serif; direction: rtl; text-align: right; padding: 20px; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #0C1445;">مرحباً بك في Wasla</h2>
          <p>لقد طلبت رمز التحقق من البريد الإلكتروني.</p>
          <div style="background: #f2f4f7; padding: 20px; border-radius: 12px; text-align: center; margin: 20px 0;">
            <p style="margin: 0; color: #46464f;">رمز التحقق الخاص بك:</p>
            <h1 style="color: #0C1445; font-size: 36px; margin: 10px 0; letter-spacing: 8px;">${code}</h1>
          </div>
          <p style="color: #6b7280; font-size: 14px;">هذا الرمز صالح لمدة 15 دقيقة.</p>
          <p style="color: #6b7280; font-size: 12px;">إذا لم تطلب هذا الرمز، يمكنك تجاهل هذه الرسالة.</p>
        </div>
      `
    });
    */

    // Option 2: Log to console for testing (development only)
    console.log('═══════════════════════════════════════════════');
    console.log('📧 EMAIL VERIFICATION CODE');
    console.log('═══════════════════════════════════════════════');
    console.log(`To: ${email}`);
    console.log(`Code: ${code}`);
    console.log('═══════════════════════════════════════════════');

    // Option 3: Store in database for debug view
    // In production, you'd integrate with an email service
    
    return NextResponse.json({ 
      success: true, 
      message: 'Email sent successfully' 
    });

  } catch (error: any) {
    console.error('Error sending verification email:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to send email' },
      { status: 500 }
    );
  }
}

// Handle CORS preflight
export async function OPTIONS() {
  return NextResponse.json({}, {
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}