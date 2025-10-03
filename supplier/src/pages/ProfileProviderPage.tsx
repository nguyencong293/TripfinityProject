import React, { useRef } from "react";
import {
  Building2,
  Mail,
  Phone,
  MapPin,
  CreditCard,
  User,
  Edit2,
  Save,
  X,
  Upload,
  Trash2,
  Loader2,
  Calendar,
  Briefcase,
  FileText,
} from "lucide-react";
import { useProfileProvider } from "../hooks/useProfileProvider";

const ProfileProviderPage: React.FC = () => {
  const {
    provider,
    user,
    loading,
    error,
    successMessage,
    showSuccessToast,
    isEditingProvider,
    isEditingUser,
    showUserModal,
    providerForm,
    userForm,
    setShowUserModal,
    handleProviderChange,
    handleUserChange,
    handleEditProvider,
    handleCancelEditProvider,
    handleSaveProvider,
    handleEditUser,
    handleCancelEditUser,
    handleSaveUser,
    handleUploadLogo,
    handleDeleteLogo,
    handleUploadAvatar,
    handleDeleteAvatar,
  } = useProfileProvider();

  const logoInputRef = useRef<HTMLInputElement>(null);
  const avatarInputRef = useRef<HTMLInputElement>(null);

  const handleLogoFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (file.size > 10 * 1024 * 1024) {
        alert("Kích thước file không được vượt quá 10MB");
        return;
      }
      if (!file.type.startsWith("image/")) {
        alert("Vui lòng chọn file ảnh");
        return;
      }
      handleUploadLogo(file);
    }
  };

  const handleAvatarFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (file.size > 10 * 1024 * 1024) {
        alert("Kích thước file không được vượt quá 10MB");
        return;
      }
      if (!file.type.startsWith("image/")) {
        alert("Vui lòng chọn file ảnh");
        return;
      }
      handleUploadAvatar(file);
    }
  };

  const formatDate = (dateString?: string) => {
    if (!dateString) return "—";
    return new Date(dateString).toLocaleDateString("vi-VN");
  };

  const getStatusBadge = (status?: string) => {
    const badges = {
      pending: "theme-bg-warning theme-text-warning",
      approved: "theme-bg-success theme-text-success",
      rejected: "theme-bg-error theme-text-error",
    };
    const statusText = {
      pending: "Đang chờ duyệt",
      approved: "Đã duyệt",
      rejected: "Bị từ chối",
    };
    return (
      <span
        className={`px-3 py-1 rounded-full caption-mobile sm:caption-tablet lg:caption-desktop ${
          badges[status as keyof typeof badges] || ""
        }`}
      >
        {statusText[status as keyof typeof statusText] || status}
      </span>
    );
  };

  if (loading && !provider && !user) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin icon-primary" />
      </div>
    );
  }

  return (
    <div className="min-h-screen theme-bg-background py-8 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
          <div>
            <h1 className="h3-mobile sm:h2-tablet lg:h1-desktop theme-text-primary">
              Hồ Sơ Nhà Cung Cấp
            </h1>
            <p className="body2-mobile sm:body1-tablet lg:body1-desktop theme-text-secondary mt-1">
              Quản lý thông tin công ty và tài khoản
            </p>
          </div>
          <button
            onClick={() => setShowUserModal(true)}
            className="btn-primary flex items-center gap-2 px-6 py-3"
          >
            <User className="h-5 w-5" />
            <span className="button-mobile sm:button-tablet lg:button-desktop">
              Thông Tin Người Dùng
            </span>
          </button>
        </div>

        {/* Error Message */}
        {error && (
          <div className="theme-bg-error border border-error theme-text-error px-4 py-3 rounded-lg body2-mobile sm:body1-tablet lg:body1-desktop">
            {error}
          </div>
        )}

        {/* Provider Information Card */}
        <div className="theme-bg-card rounded-2xl shadow-lg overflow-hidden">
          {/* Header with Logo */}
          <div className="relative h-48 theme-bg-primary">
            <div className="absolute -bottom-16 left-8">
              <div className="relative">
                {provider?.logoUrl ? (
                  <img
                    src={provider.logoUrl}
                    alt="Company Logo"
                    className="h-32 w-32 rounded-2xl border-4 theme-border theme-bg-background object-cover shadow-lg"
                  />
                ) : (
                  <div className="h-32 w-32 rounded-2xl border-4 theme-border theme-bg-background flex items-center justify-center shadow-lg">
                    <Building2 className="h-16 w-16 icon-disabled" />
                  </div>
                )}
                <div className="absolute bottom-0 right-0 flex gap-1">
                  <button
                    onClick={() => logoInputRef.current?.click()}
                    className="p-2 theme-bg-primary theme-text-button rounded-full hover:theme-bg-primary-hover shadow-lg transition-colors"
                    title="Upload logo"
                  >
                    <Upload className="h-4 w-4" />
                  </button>
                  {provider?.logoUrl && (
                    <button
                      onClick={handleDeleteLogo}
                      className="p-2 bg-light-error dark:bg-dark-error theme-text-button rounded-full hover:opacity-80 shadow-lg transition-opacity"
                      title="Xóa logo"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  )}
                </div>
                <input
                  ref={logoInputRef}
                  type="file"
                  accept="image/*"
                  onChange={handleLogoFileChange}
                  className="hidden"
                />
              </div>
            </div>
            <div className="absolute top-4 right-4">
              {getStatusBadge(provider?.providerStatus)}
            </div>
          </div>

          {/* Content */}
          <div className="pt-20 px-8 pb-8">
            <div className="flex justify-between items-start mb-6">
              <div>
                <h2 className="h4-mobile sm:h3-tablet lg:h2-desktop theme-text-primary">
                  {provider?.companyName || "Chưa có tên công ty"}
                </h2>
                <p className="body2-mobile sm:body1-tablet lg:body1-desktop theme-text-secondary mt-1">
                  Mã số thuế: {provider?.taxCode || "—"}
                </p>
              </div>
              {!isEditingProvider ? (
                <button
                  onClick={handleEditProvider}
                  className="btn-outline flex items-center gap-2"
                >
                  <Edit2 className="h-4 w-4" />
                  <span className="button-mobile sm:button-tablet lg:button-desktop">
                    Chỉnh sửa
                  </span>
                </button>
              ) : (
                <div className="flex gap-2">
                  <button
                    onClick={handleSaveProvider}
                    disabled={loading}
                    className="btn-primary flex items-center gap-2 disabled:btn-disabled"
                  >
                    {loading ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      <Save className="h-4 w-4" />
                    )}
                    <span className="button-mobile sm:button-tablet lg:button-desktop">
                      Lưu
                    </span>
                  </button>
                  <button
                    onClick={handleCancelEditProvider}
                    disabled={loading}
                    className="btn-outline flex items-center gap-2"
                  >
                    <X className="h-4 w-4" />
                    <span className="button-mobile sm:button-tablet lg:button-desktop">
                      Hủy
                    </span>
                  </button>
                </div>
              )}
            </div>

            {/* Provider Details */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Company Name */}
              <div className="space-y-2">
                <label className="flex items-center gap-2 subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                  <Building2 className="h-4 w-4" />
                  Tên công ty
                </label>
                {isEditingProvider ? (
                  <input
                    type="text"
                    name="companyName"
                    value={providerForm.companyName || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus-ring-primary body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary theme-bg-background"
                  />
                ) : (
                  <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                    {provider?.companyName || "—"}
                  </p>
                )}
              </div>

              {/* Tax Code */}
              <div className="space-y-2">
                <label className="flex items-center gap-2 subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                  <FileText className="h-4 w-4" />
                  Mã số thuế
                </label>
                {isEditingProvider ? (
                  <input
                    type="text"
                    name="taxCode"
                    value={providerForm.taxCode || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus-ring-primary body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary theme-bg-background"
                  />
                ) : (
                  <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                    {provider?.taxCode || "—"}
                  </p>
                )}
              </div>

              {/* Address */}
              <div className="space-y-2 md:col-span-2">
                <label className="flex items-center gap-2 subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                  <MapPin className="h-4 w-4" />
                  Địa chỉ
                </label>
                {isEditingProvider ? (
                  <input
                    type="text"
                    name="address"
                    value={providerForm.address || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus-ring-primary body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary theme-bg-background"
                  />
                ) : (
                  <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                    {provider?.address || "—"}
                  </p>
                )}
              </div>

              {/* Contact Email */}
              <div className="space-y-2">
                <label className="flex items-center gap-2 subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                  <Mail className="h-4 w-4" />
                  Email liên hệ
                </label>
                {isEditingProvider ? (
                  <input
                    type="email"
                    name="contactEmail"
                    value={providerForm.contactEmail || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus-ring-primary body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary theme-bg-background"
                  />
                ) : (
                  <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                    {provider?.contactEmail || "—"}
                  </p>
                )}
              </div>

              {/* Contact Phone */}
              <div className="space-y-2">
                <label className="flex items-center gap-2 subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                  <Phone className="h-4 w-4" />
                  Số điện thoại
                </label>
                {isEditingProvider ? (
                  <input
                    type="tel"
                    name="contactPhone"
                    value={providerForm.contactPhone || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus-ring-primary body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary theme-bg-background"
                  />
                ) : (
                  <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                    {provider?.contactPhone || "—"}
                  </p>
                )}
              </div>

              {/* Bank Account Number */}
              <div className="space-y-2">
                <label className="flex items-center gap-2 subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                  <CreditCard className="h-4 w-4" />
                  Số tài khoản ngân hàng
                </label>
                {isEditingProvider ? (
                  <input
                    type="text"
                    name="bankAccountNumber"
                    value={providerForm.bankAccountNumber || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus-ring-primary body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary theme-bg-background"
                  />
                ) : (
                  <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                    {provider?.bankAccountNumber || "—"}
                  </p>
                )}
              </div>

              {/* Bank Name */}
              <div className="space-y-2">
                <label className="flex items-center gap-2 subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                  <Briefcase className="h-4 w-4" />
                  Tên ngân hàng
                </label>
                {isEditingProvider ? (
                  <input
                    type="text"
                    name="bankName"
                    value={providerForm.bankName || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus-ring-primary body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary theme-bg-background"
                  />
                ) : (
                  <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                    {provider?.bankName || "—"}
                  </p>
                )}
              </div>

              {/* Description */}
              <div className="space-y-2 md:col-span-2">
                <label className="flex items-center gap-2 subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                  <FileText className="h-4 w-4" />
                  Mô tả công ty
                </label>
                {isEditingProvider ? (
                  <textarea
                    name="providerDescription"
                    value={providerForm.providerDescription || ""}
                    onChange={handleProviderChange}
                    rows={4}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus-ring-primary body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary theme-bg-background resize-none"
                  />
                ) : (
                  <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                    {provider?.providerDescription || "—"}
                  </p>
                )}
              </div>

              {/* Rating & Dates */}
              <div className="space-y-2">
                <label className="subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                  Đánh giá trung bình
                </label>
                <p className="h5-mobile sm:h5-tablet lg:h4-desktop theme-text-primary">
                  {provider?.ratingOverall
                    ? `${provider.ratingOverall.toFixed(2)} ⭐`
                    : "Chưa có đánh giá"}
                </p>
              </div>

              <div className="space-y-2">
                <label className="flex items-center gap-2 subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                  <Calendar className="h-4 w-4" />
                  Ngày tạo
                </label>
                <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                  {formatDate(provider?.createdAt)}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* User Modal */}
      {showUserModal && (
        <div className="fixed inset-0 theme-bg-overlay flex items-center justify-center z-50 p-4">
          <div className="theme-bg-card rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto shadow-lg">
            <div className="sticky top-0 theme-bg-card border-b theme-border px-6 py-4 flex justify-between items-center">
              <h2 className="h4-mobile sm:h4-tablet lg:h3-desktop theme-text-primary">
                Thông Tin Người Dùng
              </h2>
              <button
                onClick={() => {
                  setShowUserModal(false);
                  handleCancelEditUser();
                }}
                className="p-2 hover:theme-bg-secondary rounded-lg transition-colors"
              >
                <X className="h-5 w-5 theme-text-primary" />
              </button>
            </div>

            <div className="p-6 space-y-6">
              {/* Avatar */}
              <div className="flex flex-col items-center gap-4">
                {user?.avatarUrl ? (
                  <img
                    src={user.avatarUrl}
                    alt="Avatar"
                    className="h-32 w-32 rounded-full object-cover border-4 theme-border"
                  />
                ) : (
                  <div className="h-32 w-32 rounded-full border-4 theme-border theme-bg-secondary flex items-center justify-center">
                    <User className="h-16 w-16 icon-disabled" />
                  </div>
                )}
                <div className="flex gap-2">
                  <button
                    onClick={() => avatarInputRef.current?.click()}
                    className="btn-primary px-4 py-2 flex items-center gap-2"
                  >
                    <Upload className="h-4 w-4" />
                    <span className="button-mobile sm:button-tablet lg:button-desktop">
                      Upload Avatar
                    </span>
                  </button>
                  {user?.avatarUrl && (
                    <button
                      onClick={handleDeleteAvatar}
                      className="px-4 py-2 bg-light-error dark:bg-dark-error theme-text-button rounded-full hover:opacity-80 transition-opacity flex items-center gap-2"
                    >
                      <Trash2 className="h-4 w-4" />
                      <span className="button-mobile sm:button-tablet lg:button-desktop">
                        Xóa
                      </span>
                    </button>
                  )}
                </div>
                <input
                  ref={avatarInputRef}
                  type="file"
                  accept="image/*"
                  onChange={handleAvatarFileChange}
                  className="hidden"
                />
              </div>

              {/* Edit Button */}
              {!isEditingUser && (
                <button
                  onClick={handleEditUser}
                  className="btn-outline w-full flex items-center justify-center gap-2"
                >
                  <Edit2 className="h-4 w-4" />
                  <span className="button-mobile sm:button-tablet lg:button-desktop">
                    Chỉnh sửa thông tin
                  </span>
                </button>
              )}

              {/* User Details */}
              <div className="space-y-4">
                {/* Full Name */}
                <div className="space-y-2">
                  <label className="subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                    Họ và tên
                  </label>
                  {isEditingUser ? (
                    <input
                      type="text"
                      name="fullName"
                      value={userForm.fullName || ""}
                      onChange={handleUserChange}
                      className="w-full px-4 py-2 border theme-border rounded-lg focus-ring-primary body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary theme-bg-background"
                    />
                  ) : (
                    <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                      {user?.fullName || "—"}
                    </p>
                  )}
                </div>

                {/* Email */}
                <div className="space-y-2">
                  <label className="subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                    Email
                  </label>
                  <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                    {user?.email || "—"}
                  </p>
                  <p className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                    (Email không thể thay đổi)
                  </p>
                </div>

                {/* Phone Number */}
                <div className="space-y-2">
                  <label className="subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                    Số điện thoại
                  </label>
                  {isEditingUser ? (
                    <input
                      type="tel"
                      name="phoneNumber"
                      value={userForm.phoneNumber || ""}
                      onChange={handleUserChange}
                      className="w-full px-4 py-2 border theme-border rounded-lg focus-ring-primary body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary theme-bg-background"
                    />
                  ) : (
                    <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                      {user?.phoneNumber || "—"}
                    </p>
                  )}
                </div>

                {/* Date of Birth */}
                <div className="space-y-2">
                  <label className="subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                    Ngày sinh
                  </label>
                  {isEditingUser ? (
                    <input
                      type="date"
                      name="dateOfBirth"
                      value={userForm.dateOfBirth || ""}
                      onChange={handleUserChange}
                      max={(() => {
                        const today = new Date();
                        today.setFullYear(today.getFullYear() - 18);
                        return today.toISOString().split("T")[0];
                      })()}
                      className="w-full px-4 py-2 border theme-border rounded-lg focus-ring-primary body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary theme-bg-background"
                    />
                  ) : (
                    <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                      {formatDate(user?.dateOfBirth)}
                    </p>
                  )}
                </div>

                {/* Gender */}
                <div className="space-y-2">
                  <label className="subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                    Giới tính
                  </label>
                  {isEditingUser ? (
                    <select
                      name="gender"
                      value={userForm.gender || ""}
                      onChange={handleUserChange}
                      className="w-full px-4 py-2 border theme-border rounded-lg focus-ring-primary body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary theme-bg-background"
                    >
                      <option value="">Chọn giới tính</option>
                      <option value="male">Nam</option>
                      <option value="female">Nữ</option>
                      <option value="other">Khác</option>
                    </select>
                  ) : (
                    <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary">
                      {user?.gender === "male"
                        ? "Nam"
                        : user?.gender === "female"
                        ? "Nữ"
                        : user?.gender === "other"
                        ? "Khác"
                        : "—"}
                    </p>
                  )}
                </div>

                {/* Account Info */}
                <div className="grid grid-cols-2 gap-4 pt-4 border-t theme-border">
                  <div className="space-y-1">
                    <label className="subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                      Vai trò
                    </label>
                    <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary capitalize">
                      {user?.accountRole || "—"}
                    </p>
                  </div>
                  <div className="space-y-1">
                    <label className="subtitle2-mobile sm:subtitle2-tablet lg:subtitle2-desktop theme-text-secondary">
                      Trạng thái
                    </label>
                    <p className="body1-mobile sm:body1-tablet lg:body1-desktop theme-text-primary capitalize">
                      {user?.accountStatus || "—"}
                    </p>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              {isEditingUser && (
                <div className="flex gap-3 pt-4">
                  <button
                    onClick={handleSaveUser}
                    disabled={loading}
                    className="btn-primary flex-1 flex items-center justify-center gap-2 disabled:btn-disabled"
                  >
                    {loading ? (
                      <Loader2 className="h-5 w-5 animate-spin" />
                    ) : (
                      <Save className="h-5 w-5" />
                    )}
                    <span className="button-mobile sm:button-tablet lg:button-desktop">
                      Lưu thay đổi
                    </span>
                  </button>
                  <button
                    onClick={handleCancelEditUser}
                    disabled={loading}
                    className="btn-outline px-6 py-3"
                  >
                    <span className="button-mobile sm:button-tablet lg:button-desktop">
                      Hủy
                    </span>
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Success Toast */}
      {showSuccessToast && (
        <div className="fixed inset-x-0 top-4 flex justify-center z-50 pointer-events-none">
          <div className="pointer-events-auto max-w-md w-full mx-4 transform transition-all duration-300 ease-out">
            <div className="border-2 border-success theme-bg-success theme-text-primary rounded-lg shadow-lg px-4 py-3">
              <p className="text-center body1-mobile sm:body1-tablet lg:body1-desktop">
                {successMessage}
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ProfileProviderPage;
