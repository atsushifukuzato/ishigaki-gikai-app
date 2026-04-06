import { NextResponse } from "next/server";

export async function GET() {
  // Vercelが環境変数をどう認識しているかを確認するためのテスト用API
  return NextResponse.json({
    supabaseUrl: process.env.NEXT_PUBLIC_SUPABASE_URL
      ? "✅ loaded"
      : "❌ undefined",
    supabaseKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
      ? "✅ loaded"
      : "❌ undefined",
    serverSupabaseUrl: process.env.SUPABASE_URL ? "✅ loaded" : "❌ undefined",
    serviceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY
      ? "✅ loaded"
      : "❌ undefined",
    nodeEnv: process.env.NODE_ENV,
    timestamp: new Date().toISOString(),
  });
}
