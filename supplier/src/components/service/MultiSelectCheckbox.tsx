import React from "react";

/* ================= Multi-Select Checkbox Component (for number[] - IDs) ================= */
export interface MultiSelectCheckboxProps {
  options: { id: number; label: string }[];
  selectedIds: number[];
  onChange: (selectedIds: number[]) => void;
  fieldName: string;
}

const MultiSelectCheckbox: React.FC<MultiSelectCheckboxProps> = React.memo(
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  ({ options, selectedIds, onChange, fieldName }) => {
    const handleToggle = (id: number) => {
      const newSelectedIds = selectedIds.includes(id)
        ? selectedIds.filter((i) => i !== id)
        : [...selectedIds, id];

      onChange(newSelectedIds);
    };

    return (
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
        {options.map((option) => (
          <label
            key={option.id}
            className="flex items-center gap-2 p-2 rounded border theme-border hover:bg-light-secondary dark:hover:bg-dark-secondary cursor-pointer transition-colors"
          >
            <input
              type="checkbox"
              checked={selectedIds.includes(option.id)}
              onChange={() => handleToggle(option.id)}
              className="w-4 h-4 accent-light-primary dark:accent-dark-primary"
            />
            <span className="theme-text-primary text-body2-mobile sm:text-body2-tablet">
              {option.label}
            </span>
          </label>
        ))}
      </div>
    );
  }
);

MultiSelectCheckbox.displayName = "MultiSelectCheckbox";

export default MultiSelectCheckbox;
