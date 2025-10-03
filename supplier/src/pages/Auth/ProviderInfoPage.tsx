import React from "react";
import {
  X,
  Loader2,
  Building2,
  Upload,
  Image as ImageIcon,
} from "lucide-react";
import { useProviderInfo } from "../../hooks/useProviderInfo";

const ProviderInfoPage: React.FC = () => {
  const {
    formData,
    loading,
    error,
    successMessage,
    showSuccessToast,
    logoFile,
    logoPreview,
    handleChange,
    handleLogoChange,
    handleSubmit,
    handleCancel,
  } = useProviderInfo();

  return (
    <main className="relative overflow-hidden min-h-screen w-full flex items-center justify-center px-4 py-10 sm:py-12">
      {/* Background decorations */}
      <div
        className="pointer-events-none absolute inset-0 -z-10"
        aria-hidden="true"
      >
        <div className="hidden sm:block absolute -top-40 -left-32 h-[26rem] w-[26rem] rounded-full bg-gradient-to-br from-emerald-400/25 to-teal-500/30 blur-3xl animate-float-slow" />
        <div className="hidden md:block absolute top-1/2 -translate-y-1/2 -right-40 h-[30rem] w-[30rem] rounded-full bg-gradient-to-tr from-rose-400/20 via-fuchsia-500/25 to-indigo-500/25 blur-3xl animate-float-slower" />
        <div className="absolute top-24 left-[12%] h-16 w-16 sm:h-24 sm:w-24 rounded-full bg-emerald-400/30 blur-xl animate-pulse-soft" />
        <div className="absolute bottom-32 right-[18%] h-12 w-12 sm:h-20 sm:w-20 rounded-full bg-indigo-400/25 blur-lg animate-pulse-soft-delayed" />
        <div className="absolute top-[62%] left-[30%] h-12 w-12 rounded-full bg-pink-400/30 blur-lg animate-pulse-soft" />
        <div className="sm:hidden absolute top-6 right-2 h-40 w-40 rounded-full bg-gradient-to-tr from-cyan-400/20 to-sky-500/20 blur-2xl animate-float-medium" />
      </div>

      <div className="w-full max-w-2xl relative">
        <div className="w-full rounded-2xl theme-bg-card/95 backdrop-blur theme-border theme-text-primary p-6 sm:p-8 shadow-xl ring-1 ring-black/5">
          <button
            className="theme-dibutton absolute top-4 right-4"
            onClick={handleCancel}
          >
            <X className="h-5 w-5" aria-hidden="true" />
          </button>

          <div className="flex justify-center mb-4">
            <div className="p-2 rounded-full border theme-border bg-white">
              <Building2 className="h-12 sm:h-14 w-12 sm:w-14 text-emerald-600" />
            </div>
          </div>

          <h1 className="text-h4-mobile sm:text-h3-tablet lg:text-h2-desktop text-center font-semibold">
            Tạo Hồ Sơ Nhà Cung Cấp
          </h1>
          <p className="mt-2 text-center text-subtitle2-mobile theme-text-secondary">
            Vui lòng hoàn thành thông tin để tiếp tục sử dụng dịch vụ
          </p>

          {error && (
            <div className="mt-4 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
              {error}
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleSubmit} className="mt-6 sm:mt-8 space-y-4">
            {/* Company Name */}
            <div>
              <label className="block text-body1-mobile font-medium theme-text-secondary mb-1">
                Tên công ty <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                name="companyName"
                value={formData.companyName}
                onChange={handleChange}
                className="w-full rounded-lg border theme-border bg-transparent px-3 py-3 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                placeholder="Nhập tên công ty"
              />
            </div>

            {/* Tax Code */}
            <div>
              <label className="block text-body1-mobile font-medium theme-text-secondary mb-1">
                Mã số thuế <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                name="taxCode"
                value={formData.taxCode}
                onChange={handleChange}
                className="w-full rounded-lg border theme-border bg-transparent px-3 py-3 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                placeholder="Nhập mã số thuế"
              />
            </div>

            {/* Address */}
            <div>
              <label className="block text-body1-mobile font-medium theme-text-secondary mb-1">
                Địa chỉ <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                name="address"
                value={formData.address}
                onChange={handleChange}
                className="w-full rounded-lg border theme-border bg-transparent px-3 py-3 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                placeholder="Nhập địa chỉ công ty"
              />
            </div>

            {/* Contact Email */}
            <div>
              <label className="block text-body1-mobile font-medium theme-text-secondary mb-1">
                Email liên hệ <span className="text-red-500">*</span>
              </label>
              <input
                type="email"
                name="contactEmail"
                value={formData.contactEmail}
                onChange={handleChange}
                className="w-full rounded-lg border theme-border bg-transparent px-3 py-3 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                placeholder="Nhập email liên hệ"
              />
            </div>

            {/* Contact Phone */}
            <div>
              <label className="block text-body1-mobile font-medium theme-text-secondary mb-1">
                Số điện thoại <span className="text-red-500">*</span>
              </label>
              <input
                type="tel"
                name="contactPhone"
                value={formData.contactPhone}
                onChange={handleChange}
                className="w-full rounded-lg border theme-border bg-transparent px-3 py-3 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                placeholder="Nhập số điện thoại"
              />
            </div>

            {/* Bank Account Number */}
            <div>
              <label className="block text-body1-mobile font-medium theme-text-secondary mb-1">
                Số tài khoản ngân hàng
              </label>
              <input
                type="text"
                name="bankAccountNumber"
                value={formData.bankAccountNumber}
                onChange={handleChange}
                className="w-full rounded-lg border theme-border bg-transparent px-3 py-3 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                placeholder="Nhập số tài khoản (tùy chọn)"
              />
            </div>

            {/* Bank Name */}
            <div>
              <label className="block text-body1-mobile font-medium theme-text-secondary mb-1">
                Tên ngân hàng
              </label>
              <input
                type="text"
                name="bankName"
                value={formData.bankName}
                onChange={handleChange}
                className="w-full rounded-lg border theme-border bg-transparent px-3 py-3 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                placeholder="Nhập tên ngân hàng (tùy chọn)"
              />
            </div>

            {/* Logo Upload */}
            <div>
              <label className="block text-body1-mobile font-medium theme-text-secondary mb-1">
                Logo công ty
              </label>
              <div className="mt-2">
                <div className="flex items-center gap-4">
                  {/* Preview */}
                  <div className="flex-shrink-0">
                    {logoPreview ? (
                      <img
                        src={logoPreview}
                        alt="Logo preview"
                        className="h-20 w-20 rounded-lg object-cover border theme-border"
                      />
                    ) : (
                      <div className="h-20 w-20 rounded-lg border-2 border-dashed theme-border flex items-center justify-center bg-gray-50 dark:bg-gray-800">
                        <ImageIcon className="h-8 w-8 text-gray-400" />
                      </div>
                    )}
                  </div>

                  {/* Upload Button */}
                  <div className="flex-1">
                    <label
                      htmlFor="logo-upload"
                      className="cursor-pointer inline-flex items-center px-4 py-2 border theme-border rounded-lg text-sm font-medium theme-text-primary hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                    >
                      <Upload className="h-4 w-4 mr-2" />
                      {logoFile ? "Thay đổi logo" : "Chọn logo"}
                    </label>
                    <input
                      id="logo-upload"
                      type="file"
                      accept="image/*"
                      onChange={handleLogoChange}
                      className="hidden"
                    />
                    {logoFile && (
                      <p className="mt-1 text-xs theme-text-secondary">
                        {logoFile.name}
                      </p>
                    )}
                    <p className="mt-1 text-xs theme-text-secondary">
                      PNG, JPG, GIF tối đa 10MB
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Description */}
            <div>
              <label className="block text-body1-mobile font-medium theme-text-secondary mb-1">
                Mô tả công ty
              </label>
              <textarea
                name="providerDescription"
                value={formData.providerDescription}
                onChange={handleChange}
                rows={4}
                className="w-full rounded-lg border theme-border bg-transparent px-3 py-3 focus:outline-none focus:ring-2 focus:ring-emerald-500 resize-none"
                placeholder="Nhập mô tả về công ty của bạn (tùy chọn)"
              />
            </div>

            {/* Submit Buttons */}
            <div className="flex flex-col sm:flex-row gap-3 pt-2">
              <button
                type="submit"
                disabled={loading}
                className={`btn-primary flex-1 h-12 rounded-full font-semibold flex items-center justify-center ${
                  loading ? "opacity-70 cursor-not-allowed" : ""
                }`}
              >
                {loading ? (
                  <>
                    <Loader2 className="animate-spin h-5 w-5 mr-2" />
                    Đang xử lý...
                  </>
                ) : (
                  "Tạo Hồ Sơ"
                )}
              </button>
              <button
                type="button"
                onClick={handleCancel}
                disabled={loading}
                className="h-12 px-6 rounded-full border theme-border theme-text-primary hover:bg-gray-50 dark:hover:bg-gray-800 font-semibold transition-colors disabled:opacity-50"
              >
                Hủy
              </button>
            </div>
          </form>
        </div>
      </div>

      {/* Success Toast */}
      {showSuccessToast && (
        <div className="fixed inset-x-0 top-4 flex justify-center z-50 pointer-events-none">
          <div
            className={`pointer-events-auto max-w-md w-full mx-4 transition-transform duration-300 ease-out transform ${
              showSuccessToast ? "translate-y-0" : "-translate-y-full"
            }`}
          >
            <div className="border-2 border-success theme-bg-success theme-text-primary rounded-lg shadow-lg px-4 py-3">
              <p className="text-center font-medium">{successMessage}</p>
            </div>
          </div>
        </div>
      )}
    </main>
  );
};

export default ProviderInfoPage;
