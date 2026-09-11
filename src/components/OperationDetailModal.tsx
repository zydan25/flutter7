import React from "react";
import { OperationItem } from "../types";
import { X, CheckCircle, Clock } from "lucide-react";

interface OperationDetailModalProps {
  operation: OperationItem;
  onClose: () => void;
  onStatusUpdated?: (op: OperationItem) => void;
}

export const OperationDetailModal: React.FC<OperationDetailModalProps> = ({
  operation,
  onClose,
}) => {
  return (
    <div className="fixed inset-0 z-50 bg-black/40 flex items-center justify-center p-4 backdrop-blur-xs">
      <div className="bg-white rounded-3xl p-5 max-w-sm w-full space-y-4 shadow-xl border border-slate-200">
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-black text-slate-900">تفاصيل العملية #{operation.id}</h3>
          <button onClick={onClose} className="p-1 rounded-full hover:bg-slate-100 text-slate-500">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="space-y-2 text-xs">
          <div className="flex justify-between py-1 border-b border-slate-100">
            <span className="text-slate-500 font-bold">الخدمة:</span>
            <span className="font-black text-slate-900">{operation.service || operation.packageName || "سداد رصيد"}</span>
          </div>
          <div className="flex justify-between py-1 border-b border-slate-100">
            <span className="text-slate-500 font-bold">رقم الهاتف:</span>
            <span className="font-mono font-bold text-slate-900">{operation.phoneNumber || operation.phone || operation.mobile || "—"}</span>
          </div>
          <div className="flex justify-between py-1 border-b border-slate-100">
            <span className="text-slate-500 font-bold">المبلغ:</span>
            <span className="font-black text-[#8B1D3B]">{Number(operation.amount).toLocaleString()} ر.ي</span>
          </div>
          <div className="flex justify-between py-1 border-b border-slate-100">
            <span className="text-slate-500 font-bold">الحالة:</span>
            <span className="font-bold text-emerald-600">{operation.status}</span>
          </div>
          {operation.provider_transaction_id && (
            <div className="flex justify-between py-1 border-b border-slate-100">
              <span className="text-slate-500 font-bold">رقم مرجع المزود:</span>
              <span className="font-mono text-slate-700">{operation.provider_transaction_id}</span>
            </div>
          )}
        </div>

        <button
          onClick={onClose}
          className="w-full py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-800 rounded-xl text-xs font-bold"
        >
          إغلاق
        </button>
      </div>
    </div>
  );
};
