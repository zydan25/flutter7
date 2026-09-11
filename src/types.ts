export interface OperationItem {
  id: string | number;
  service?: string;
  packageName?: string;
  item_name?: string;
  phoneNumber?: string;
  phone?: string;
  mobile?: string;
  amount: number | string;
  date?: string;
  created_at?: string;
  status: string;
  statusText?: string;
  isRealVerified?: boolean;
  orderNumber?: string;
  operationNumber?: string;
  customerName?: string;
  operatorName?: string;
  fee?: number;
  totalCost?: number;
  balanceBefore?: number;
  balanceAfter?: number;
  time?: string;
  transid?: string | number;
  transId?: string | number;
  provider_transaction_id?: string | number;
  currency?: string;
  notes?: string;
  type?: string;
}

export interface UserProfile {
  id: number;
  phone: string;
  first_name?: string;
  middle_name?: string;
  third_name?: string;
  last_name?: string;
  governorate?: string;
  role?: string;
  avatar?: string | null;
  points_balance?: number;
  account_type?: string;
  balanceYer?: number;
  balance?: number;
}
