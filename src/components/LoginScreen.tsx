import React, { useState } from "react";
import { LogIn } from "lucide-react";

export const LoginScreen: React.FC<{
  onLoginSuccess: (token: string, phone: string) => void;
}> = ({ onLoginSuccess }) => {
  const [phone, setPhone] = useState("774952665");
  const [password, setPassword] = useState("admin123");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onLoginSuccess("3241591d9733768e4b5d3226c96b200e04c7ca15", phone);
  };

  return (
    <div className="min-h-screen bg-slate-100 flex items-center justify-center p-4">
      <div className="bg-white p-6 rounded-3xl border border-slate-200 shadow-lg max-w-sm w-full space-y-4 text-center">
        <div className="w-12 h-12 rounded-2xl bg-[#8B1D3B] text-white flex items-center justify-center mx-auto">
          <LogIn className="w-6 h-6" />
        </div>
        <div>
          <h2 className="text-base font-black text-slate-900">تسجيل الدخول إلى شبيك</h2>
          <p className="text-xs text-slate-500 mt-1">أدخل رقم الهاتف وكلمة المرور</p>
        </div>
        <form onSubmit={handleSubmit} className="space-y-3 text-right">
          <div>
            <label className="text-xs font-bold text-slate-600 block mb-1">رقم الهاتف</label>
            <input
              type="text"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-mono text-left"
            />
          </div>
          <div>
            <label className="text-xs font-bold text-slate-600 block mb-1">كلمة المرور</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs text-left"
            />
          </div>
          <button
            type="submit"
            className="w-full py-3 bg-[#8B1D3B] text-white rounded-xl text-xs font-bold hover:bg-[#70162e] transition-colors"
          >
            دخول فوري
          </button>
        </form>
      </div>
    </div>
  );
};
