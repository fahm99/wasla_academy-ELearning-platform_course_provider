مل -- ============================================
-- Email Verification System SQL for Supabase
-- ============================================

-- 1. Create email_verifications table
CREATE TABLE IF NOT EXISTS email_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL,
  code TEXT NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_email_verifications_email 
  ON email_verifications(email);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE email_verifications ENABLE ROW LEVEL SECURITY;

-- 3. Create policies
-- Allow anyone to create verification (for registration)
CREATE POLICY "Allow insert for verification" 
  ON email_verifications FOR INSERT 
  WITH CHECK (true);

-- Allow users to read their own verification
CREATE POLICY "Allow read own verification" 
  ON email_verifications FOR SELECT 
  USING (auth.uid() = user_id OR auth.uid() IS NULL);

-- Allow users to update their own verification
CREATE POLICY "Allow update own verification" 
  ON email_verifications FOR UPDATE 
  USING (auth.uid() = user_id);

-- Allow delete for own verification
CREATE POLICY "Allow delete own verification" 
  ON email_verifications FOR DELETE 
  USING (auth.uid() = user_id);

-- 4. Function to verify email
CREATE OR REPLACE FUNCTION verify_email(p_email TEXT, p_code TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  v_verification RECORD;
  v_success BOOLEAN := FALSE;
BEGIN
  -- Find valid verification code
  SELECT * INTO v_verification
  FROM email_verifications
  WHERE email = p_email
    AND code = p_code
    AND expires_at > NOW()
    AND verified = FALSE
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_verification IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Mark as verified
  UPDATE email_verifications
  SET verified = TRUE, 
      verified_at = NOW()
  WHERE id = v_verification.id;

  -- Update auth.users email_confirmed_at
  UPDATE auth.users
  SET email_confirmed_at = NOW()
  WHERE id = v_verification.user_id;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Function to generate and send verification code
CREATE OR REPLACE FUNCTION generate_verification_code(p_email TEXT)
RETURNS TEXT AS $$
DECLARE
  v_code TEXT;
  v_expires_at TIMESTAMPTZ;
BEGIN
  -- Generate 6-digit code
  v_code := LPAD(FLOOR(RANDOM() * 900000 + 100000)::TEXT, 6, '0');
  
  -- Set expiry to 15 minutes
  v_expires_at := NOW() + INTERVAL '15 minutes';

  -- Delete old codes for this email
  DELETE FROM email_verifications WHERE email = p_email;

  -- Insert new code
  INSERT INTO email_verifications (email, code, expires_at)
  VALUES (p_email, v_code, v_expires_at);

  RETURN v_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- EMAIL SENDING CONFIGURATION
-- ============================================

-- Option 1: Using Supabase Edge Function with Resend (Recommended)
-- Create edge function: supabase/functions/send-verification-email/index.ts

/*
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { Resend } from 'https://esm.sh/resend@2.0.0';

const resend = new Resend(Deno.env.get('RESEND_API_KEY'));

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { email, code } = await req.json();

    const data = await resend.emails.send({
      from: 'Wasla <noreply@yourdomain.com>',
      to: email,
      subject: 'رمز التحقق من البريد الإلكتروني',
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
      `,
    });

    return new Response(JSON.stringify(data), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
*/

-- Option 2: Using Inbucket for local development (already included in Supabase)
-- Emails will be captured in Inbucket dashboard

-- ============================================
-- HOW TO SET UP EMAIL SENDING IN SUPABASE DASHBOARD
-- ============================================

/*
Step 1: Go to Supabase Dashboard > Edge Functions
Step 2: Create new function called "send-verification-email"
Step 3: Deploy the function with Resend API

Step 4: In your Next.js app, call the edge function:

const sendVerificationEmail = async (email: string, code: string) => {
  const response = await fetch(`${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/send-verification-email`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, code }),
  });
  return response.json();
};

Step 5: Update the register page to call this function after creating the code.
*/

-- ============================================
-- TESTING QUERIES
-- ============================================

-- Test generating a code
-- SELECT generate_verification_code('test@example.com');

-- Test verifying email
-- SELECT verify_email('test@example.com', '123456');

-- View all verifications (for testing)
-- SELECT * FROM email_verifications ORDER BY created_at DESC;