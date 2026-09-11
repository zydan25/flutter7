import React from "react";
import { ArrowRight } from "lucide-react";

export const UserProfileScreen: React.FC<{ onBack: () => void }> = ({ onBack }) => (
  <div className="p-4 space-y-4">
    <div className="flex items-center gap-2">
      <button onClick={onBack} className="p-2 rounded-full hover:bg-slate-100">
        <ArrowRight className="w-5 h-5" />
      </button>
      <h2 className="text-base font-bold">الملف الشخصي</h2>
    </div>
  </div>
);
