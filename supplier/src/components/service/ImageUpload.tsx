import React from "react";
import { Upload, Trash2 } from "lucide-react";

const labelCls =
  "font-medium theme-text-primary text-caption-mobile sm:text-caption-tablet lg:text-caption-desktop";

export interface ImageUploadProps {
  label: string;
  multiple?: boolean;
  onSelect: (files: File[]) => void;
  preview?: string | string[] | null;
  onRemove?: () => void;
  onRemoveMultiple?: (index: number) => void;
}

const ImageUpload: React.FC<ImageUploadProps> = ({
  label,
  multiple,
  onSelect,
  preview,
  onRemove,
  onRemoveMultiple,
}) => {
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []);
    if (files.length > 0) {
      onSelect(files);
    }
  };

  return (
    <div className="flex flex-col gap-2">
      <label className={labelCls}>{label}</label>
      <div className="border-2 theme-border border-dashed rounded p-4 flex flex-col items-center gap-2 cursor-pointer hover:bg-light-secondary dark:hover:bg-dark-secondary">
        <Upload className="w-5 h-5 icon-brand" />
        <input
          type="file"
          accept="image/*"
          multiple={multiple}
          onChange={handleFileChange}
          className="hidden"
          id={`file-upload-${label}`}
        />
        <label
          htmlFor={`file-upload-${label}`}
          className="cursor-pointer theme-text-secondary text-body2-mobile sm:text-body2-tablet"
        >
          {label}
        </label>
      </div>

      {preview && (
        <div className="grid gap-3 grid-cols-2 sm:grid-cols-3 md:grid-cols-4 mt-2">
          {Array.isArray(preview) ? (
            preview.map((url, index) => (
              <div key={index} className="relative group">
                <img
                  src={url}
                  alt={`Preview ${index}`}
                  className="w-full h-28 object-cover rounded border theme-border"
                />
                {onRemoveMultiple && (
                  <button
                    onClick={() => onRemoveMultiple(index)}
                    className="absolute top-1 right-1 p-1 bg-white/90 rounded hover:bg-white"
                    type="button"
                  >
                    <Trash2 className="w-3 h-3 theme-text-error" />
                  </button>
                )}
              </div>
            ))
          ) : (
            <div className="relative group">
              <img
                src={preview}
                alt="Preview"
                className="w-full h-28 object-cover rounded border theme-border"
              />
              {onRemove && (
                <button
                  onClick={() => onRemove()}
                  className="absolute top-1 right-1 p-1 bg-white/90 rounded hover:bg-white"
                  type="button"
                >
                  <Trash2 className="w-3 h-3 theme-text-error" />
                </button>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default ImageUpload;
