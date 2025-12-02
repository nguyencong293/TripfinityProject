import React from "react";

/* ================= Multi-Select Checkbox Component for Strings (for string[] - Badges, etc.) ================= */
export interface MultiSelectCheckboxStringProps {
  options: { value: string; label: string; icon?: string; flag?: string }[];
  selectedValues: string[];
  onChange: (selectedValues: string[]) => void;
  fieldName: string;
}

const MultiSelectCheckboxString: React.FC<MultiSelectCheckboxStringProps> = React.memo(
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  ({ options, selectedValues, onChange, fieldName }) => {
    const handleToggle = (value: string) => {
      const newSelectedValues = selectedValues.includes(value)
        ? selectedValues.filter((v) => v !== value)
        : [...selectedValues, value];

      onChange(newSelectedValues);
    };

    return (
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
        {options.map((option) => (
          <label
            key={option.value}
            className="flex items-center gap-2 p-2 rounded border theme-border hover:bg-light-secondary dark:hover:bg-dark-secondary cursor-pointer transition-colors"
          >
            <input
              type="checkbox"
              checked={selectedValues.includes(option.value)}
              onChange={() => handleToggle(option.value)}
              className="w-4 h-4 accent-light-primary dark:accent-dark-primary"
            />
            <span className="theme-text-primary text-body2-mobile sm:text-body2-tablet">
              {option.icon && <span className="mr-1">{option.icon}</span>}
              {option.flag && <span className="mr-1">{option.flag}</span>}
              {option.label}
            </span>
          </label>
        ))}
      </div>
    );
  }
);

MultiSelectCheckboxString.displayName = "MultiSelectCheckboxString";

export default MultiSelectCheckboxString;
