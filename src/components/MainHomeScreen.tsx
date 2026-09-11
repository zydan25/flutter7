import React from "react";
import { UserProfile, OperationItem } from "../types";
import {
  CreditCard,
  BarChart3,
  Wifi,
  Gamepad2,
  MessageSquare,
  MapPin,
  Send,
  ShoppingBag,
  RefreshCw,
  Eye,
  CheckCircle2,
  ShieldCheck,
  Grid,
} from "lucide-react";

interface MainHomeScreenProps {
  walletBalance: number;
  userProfile: UserProfile | null;
  onRefreshBalance: () => void;
  onNavigate: (screen: string) => void;
  operations?: OperationItem[];
  onSelectOperation?: (op: OperationItem) => void;
  onFeedSuccess?: () => void;
  onLogout?: () => void;
}

export const MainHomeScreen: React.FC<MainHomeScreenProps> = ({
  walletBalance,
  userProfile,
  onRefreshBalance,
  onNavigate,
  operations = [],
}) => {
  const [showBalance, setShowBalance] = React.useState(true);
  const [activeCurrency, setActiveCurrency] = React.useState("YER");

  const menuItems = [
    { id: "payment", label: "شبكة السداد", icon: CreditCard, color: "bg-rose-50 text-[#8B1D3B] border-rose-200" },
    { id: "reports", label: "التقارير", icon: BarChart3, color: "bg-sky-50 text-sky-600 border-sky-200" },
    { id: "operations", label: "الخدمات", icon: Grid, color: "bg-purple-50 text-purple-600 border-purple-200" },
    { id: "wifi", label: "كروت الشبكات", icon: Wifi, color: "bg-emerald-50 text-emerald-600 border-emerald-200" },
    { id: "games", label: "شحن الألعاب", icon: Gamepad2, color: "bg-amber-50 text-amber-600 border-amber-200" },
    { id: "chat", label: "شحن البرامج", icon: MessageSquare, color: "bg-indigo-50 text-indigo-600 border-indigo-200" },
    { id: "addresses", label: "دفتر العناوين", icon: MapPin, color: "bg-amber-50 text-amber-700 border-amber-200" },
    { id: "transfer", label: "تحويل مالي", icon: Send, color: "bg-blue-50 text-blue-600 border-blue-200" },
    { id: "store", label: "طلباتي (4)", icon: ShoppingBag, color: "bg-emerald-50 text-emerald-700 border-emerald-200" },
  ];

  return (
    <div className="p-4 space-y-4">
      {/* Verified Account Header */}
      <div className="bg-white p-3.5 rounded-2xl border border-slate-200 flex items-center justify-between shadow-xs">
        <div className="flex items-center gap-3">
          <div className="w-11 h-11 rounded-full bg-slate-100 border-2 border-emerald-500 flex items-center justify-center text-slate-700 font-black">
            {userProfile?.first_name ? userProfile.first_name[0] : "م"}
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <span className="text-xs font-black text-slate-900">
                الحساب الموثق: {userProfile?.first_name || "المستخدم"} {userProfile?.last_name || ""}
              </span>
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600 inline" />
            </div>
            <p className="text-[11px] text-slate-500 font-semibold">
              الهاتف: {userProfile?.phone || "774952665"} • المحافظة: {userProfile?.governorate || "إب"}
            </p>
            <div className="flex items-center gap-2 mt-1">
              <span className="text-[10px] bg-amber-50 text-amber-700 border border-amber-200 px-1.5 py-0.5 rounded font-bold">
                {userProfile?.points_balance || 0} نقطة ولاء
              </span>
              <span className="text-[10px] text-slate-400 font-semibold">صلاحيات الحساب: عميل ومشتري</span>
            </div>
          </div>
        </div>
        <div className="flex items-center gap-1 bg-emerald-50 text-emerald-700 border border-emerald-200 px-2 py-1 rounded-lg text-[10px] font-bold">
          <ShieldCheck className="w-3 h-3" />
          <span>معتمد من الخادم</span>
        </div>
      </div>

      {/* Digital Wallet Card */}
      <div className="bg-linear-to-bl from-[#1E293B] via-[#0F172A] to-[#8B1D3B] text-white p-4 rounded-3xl shadow-md space-y-3">
        <div className="flex items-center justify-between text-xs text-slate-300">
          <div className="flex items-center gap-1.5">
            <CreditCard className="w-4 h-4 text-rose-300" />
            <span className="font-bold">البطاقة الرقمية والمحفظة</span>
          </div>
          <div className="flex items-center gap-2">
            <button onClick={() => setShowBalance(!showBalance)} className="p-1 hover:text-white">
              <Eye className="w-4 h-4" />
            </button>
            <button onClick={onRefreshBalance} className="p-1 hover:text-white">
              <RefreshCw className="w-4 h-4" />
            </button>
          </div>
        </div>

        <div>
          <p className="text-xs text-slate-400 font-semibold">الرصيد المتاح للعمليات</p>
          <div className="text-2xl font-black tracking-tight mt-0.5 text-white">
            {showBalance ? `${Number(walletBalance).toLocaleString()} ريال يمني` : "••••••••"}
          </div>
          <p className="text-[10px] text-slate-400 mt-1 font-mono">
            رقم العميل المعتمد: #{userProfile?.id || 11}
          </p>
        </div>

        {/* Currency Switcher */}
        <div className="flex gap-1.5 pt-1">
          {["YER", "SAR", "USD"].map((cur) => (
            <button
              key={cur}
              onClick={() => setActiveCurrency(cur)}
              className={`px-3 py-1 rounded-full text-xs font-bold transition-all ${
                activeCurrency === cur
                  ? "bg-white text-slate-900 shadow-xs"
                  : "bg-white/10 text-white hover:bg-white/20"
              }`}
            >
              {cur === "YER" ? "يمني (نشط)" : cur === "SAR" ? "سعودي" : "دولار $"}
            </button>
          ))}
        </div>
      </div>

      {/* 3x3 Grid Services */}
      <div>
        <h3 className="text-xs font-black text-slate-800 mb-2.5">الخدمات والمدفوعات الإلكترونية</h3>
        <div className="grid grid-cols-3 gap-2.5">
          {menuItems.map((item) => {
            const Icon = item.icon;
            return (
              <button
                key={item.id}
                onClick={() => onNavigate(item.id)}
                className={`p-3 rounded-2xl border flex flex-col items-center justify-center gap-2 transition-all hover:scale-102 active:scale-98 shadow-2xs ${item.color}`}
              >
                <div className="w-8 h-8 rounded-xl flex items-center justify-center bg-white/80 shadow-2xs">
                  <Icon className="w-4 h-4" />
                </div>
                <span className="text-[11px] font-black">{item.label}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Action Cards Row */}
      <div className="grid grid-cols-3 gap-2 pt-1">
        <button
          onClick={() => onNavigate("statement")}
          className="p-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 border border-slate-200 text-slate-800 text-xs font-bold text-center"
        >
          تغذية الحساب
        </button>
        <button
          onClick={() => onNavigate("transfer")}
          className="p-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 border border-slate-200 text-slate-800 text-xs font-bold text-center"
        >
          تحويل مالي
        </button>
        <button
          onClick={() => onNavigate("store")}
          className="p-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 border border-slate-200 text-slate-800 text-xs font-bold text-center"
        >
          طلباتي
        </button>
      </div>
    </div>
  );
};
