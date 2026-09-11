import { OperationItem, UserProfile } from "../types";

const TOKEN = "3241591d9733768e4b5d3226c96b200e04c7ca15";
const BASE_URL = "https://shopik.alattab.site/api";

const headers = {
  Accept: "application/json",
  "Content-Type": "application/json",
  Authorization: `Token ${TOKEN}`,
};

export async function fetchLiveUserProfile(): Promise<UserProfile | null> {
  try {
    const res = await fetch(`${BASE_URL}/auth/me/`, { headers });
    if (!res.ok) return null;
    return await res.json();
  } catch {
    return null;
  }
}

export async function fetchLiveWalletBalance(): Promise<number> {
  try {
    const res = await fetch(`${BASE_URL}/v2/accounting/wallets/me/balance/?currency=YER`, { headers });
    if (!res.ok) return 5420;
    const data = await res.json();
    const available = data.customer?.available ?? data.available;
    return available ? parseFloat(available) : 5420;
  } catch {
    return 5420;
  }
}

export async function fetchLiveServerReports(): Promise<OperationItem[]> {
  try {
    const res = await fetch(`${BASE_URL}/v2/services/requests/reports/`, { headers });
    if (!res.ok) return [];
    const data = await res.json();
    return Array.isArray(data) ? data : data.results || [];
  } catch {
    return [];
  }
}
