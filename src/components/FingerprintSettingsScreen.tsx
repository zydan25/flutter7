import React from "react";
import { UserProfile } from "../types";
import { ArrowRight, LogOut, MapPin, User } from "lucide-react";

export const FingerprintSettingsScreen: React.FC<{ onBack: () => void }> = ({ onBack }) => (
  <div className="p-4 space-y-4">
    <div className="flex items-center gap-2">
      <button onClick={onBack} className="p-2 rounded-full hover:bg-slate-100">
        <ArrowRight className="w-5 h-5" />
      </button>
      <h2 className="text-base font-bold">إعدادات البصمة والحماية</h2>
    </div>
    <div className="p-4 bg-white rounded-2xl border border-slate-200">
      <p className="text-xs text-slate-600">يمكنك تفعيل تسجيل الدخول بالبصمة البيومترية لتأمين حسابك وسرعة الدخول.</p>
    </div>
  </div>
);

export const SettingsScreen: React.FC<{
  onBack: () => void;
  onNavigateToAddresses: () => void;
  onNavigateToProfileEdit: () => void;
  onLogout: () => void;
}> = ({ onBack, onNavigateToAddresses, onNavigateToProfileEdit, onLogout }) => (
  <div className="p-4 space-y-4">
    <div className="flex items-center gap-2">
      <button onClick={onBack} className="p-2 rounded-full hover:bg-slate-100">
        <ArrowRight className="w-5 h-5" />
      </button>
      <h2 className="text-base font-black text-slate-900">الإعدادات</h2>
    </div>
    <div className="bg-white rounded-2xl border border-slate-200 divide-y divide-slate-100">
      <button
        onClick={onNavigateToProfileEdit}
        className="w-full p-3.5 flex items-center justify-between text-xs font-bold text-slate-800 hover:bg-slate-50"
      >
        <div className="flex items-center gap-2">
          <User className="w-4 h-4 text-slate-500" />
          <span>الملف الشخصي والحساب</span>
        </div>
        <span className="text-slate-400">←</span>
      </button>
      <button
        onClick={onNavigateToAddresses}
        className="w-full p-3.5 flex items-center justify-between text-xs font-bold text-slate-800 hover:bg-slate-50"
      >
        <div className="flex items-center gap-2">
          <MapPin className="w-4 h-4 text-slate-500" />
          <span>دفتر العناوين المعتمدة</span>
        </div>
        <span className="text-slate-400">←</span>
      </button>
      <button
        onClick={onLogout}
        className="w-full p-3.5 flex items-center justify-between text-xs font-bold text-rose-600 hover:bg-rose-50"
      >
        <div className="flex items-center gap-2">
          <LogOut className="w-4 h-4" />
          <span>تسجيل الخروج</span>
        </div>
      </button>
    </div>
  </div>
);

export const UserProfileEditScreen: React.FC<{
  userProfile: UserProfile | null;
  onBack: () => void;
  onUpdateProfile?: (p: Partial<UserProfile>) => void;
}> = ({ userProfile, onBack }) => (
  <div className="p-4 space-y-4">
    <div className="flex items-center gap-2">
      <button onClick={onBack} className="p-2 rounded-full hover:bg-slate-100">
        <ArrowRight className="w-5 h-5" />
      </button>
      <h2 className="text-base font-black text-slate-900">تعديل الملف الشخصي</h2>
    </div>
    <div className="bg-white p-4 rounded-2xl border border-slate-200 space-y-3">
      <div>
        <label className="text-xs font-bold text-slate-600 block mb-1">الاسم</label>
        <input
          type="text"
          defaultValue={userProfile?.first_name || ""}
          className="w-full p-2 bg-slate-50 border border-slate-200 rounded-xl text-xs"
        />
      </div>
      <div>
        <label className="text-xs font-bold text-slate-600 block mb-1">الهاتف</label>
        <input
          type="text"
          readOnly
          defaultValue={userProfile?.phone || ""}
          className="w-full p-2 bg-slate-100 border border-slate-200 rounded-xl text-xs text-slate-500"
        />
      </div>
    </div>
  </div>
);
