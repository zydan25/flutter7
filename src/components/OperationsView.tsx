import React from "react";
import { OperationItem } from "../types";
import { ArrowRight, RefreshCw, CheckCircle, Clock, XCircle, Search } from "lucide-react";

interface OperationsViewProps {
  operations: OperationItem[];
  onBack: () => void;
  onSelectOperation?: (op: OperationItem) => void;
  onRefresh?: () => void;
}

export const OperationsView: React.FC<OperationsViewProps> = ({
  operations,
  onBack,
  onSelectOperation,
  onRefresh,
}) => {
  const [filter, setFilter] = React.useState("all");

  return (
    <div className="p-4 space-y-4">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <button onClick={onBack} className="p-2 rounded-full hover:bg-slate-100">
            <ArrowRight className="w-5 h-5 text-slate-700" />
          </button>
          <h2 className="text-base font-black text-slate-900">سجل العمليات والطلبات</h2>
        </div>
        {onRefresh && (
          <button onClick={onRefresh} className="p-2 rounded-full hover:bg-slate-100 text-slate-600">
            <RefreshCw className="w-4 h-4" />
          </button>
        )}
      </div>

      <div className="space-y-2">
        {operations.length === 0 ? (
          <div className="text-center py-10 text-slate-400 text-xs font-bold">لا توجد عمليات مسجلة</div>
        ) : (
          operations.map((op) => (
            <div
              key={op.id}
              onClick={() => onSelectOperation?.(op)}
              className="p-3 bg-white border border-slate-200 rounded-2xl flex items-center justify-between cursor-pointer hover:border-slate-300"
            >
              <div>
                <p className="text-xs font-black text-slate-900">{op.service || op.packageName || "عملية سداد"}</p>
                <p className="text-[11px] text-slate-500 font-semibold">{op.phoneNumber || op.phone || op.mobile || "—"}</p>
              </div>
              <div className="text-left">
                <p className="text-xs font-black text-[#8B1D3B]">{Number(op.amount).toLocaleString()} ر.ي</p>
                <span className={`text-[10px] px-1.5 py-0.5 rounded font-bold ${
                  op.status === "success" ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700"
                }`}>
                  {op.status === "success" ? "ناجحة" : op.status}
                </span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};
