import React from "react";
import { ArrowRight, Wifi } from "lucide-react";

export const WifiNetworksScreen: React.FC<{
  walletBalance: number;
  onBack: () => void;
  onBuyCard?: (amt: number) => void;
}> = ({ walletBalance, onBack }) => (
  <div className="p-4 space-y-4">
    <div className="flex items-center gap-2">
      <button onClick={onBack} className="p-2 rounded-full hover:bg-slate-100">
        <ArrowRight className="w-5 h-5" />
      </button>
      <h2 className="text-base font-black text-slate-900">كروت شبكات الوايفاي المحلية</h2>
    </div>
    <div className="bg-white p-4 rounded-2xl border border-slate-200">
      <p className="text-xs text-slate-600 font-bold">شراء كروت وبطاقات شبكات الوايفاي المعتمدة بأسعار الجملة.</p>
    </div>
  </div>
);
