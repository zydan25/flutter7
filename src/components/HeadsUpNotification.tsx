import React from "react";

export function triggerHeadsUpNotification(title: string, body: string) {
  console.log(`[Notification] ${title}: ${body}`);
}

export const HeadsUpNotificationContainer: React.FC<{ notifications?: any[] }> = ({ notifications = [] }) => {
  return null;
};
