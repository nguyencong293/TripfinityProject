import React from "react";
import { ChevronRight } from "lucide-react";

export interface QuickActionProps {
  icon: React.ReactNode;
  label: string;
  description: string;
  onClick: () => void;
}

const QuickAction: React.FC<QuickActionProps> = ({
  icon,
  label,
  description,
  onClick,
}) => (
  <button
    onClick={onClick}
    className="group relative rounded-xl border theme-border theme-bg-card p-6 transition-all hover:shadow-lg text-left w-full"
  >
    <div className="flex items-start gap-4">
      <div className="p-3 rounded-lg theme-bg-secondary">{icon}</div>
      <div className="flex-1">
        <h4 className="text-base font-semibold mb-1 theme-text-primary">
          {label}
        </h4>
        <p className="text-sm theme-text-secondary">{description}</p>
      </div>
      <ChevronRight className="w-5 h-5 icon-disabled transition-transform group-hover:translate-x-1" />
    </div>
  </button>
);

export default QuickAction;
