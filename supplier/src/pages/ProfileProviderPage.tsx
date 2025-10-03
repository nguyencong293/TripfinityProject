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
      pending:
        "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200",
      approved:
        "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200",
      rejected: "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200",
    };
    const statusText = {
      pending: "Đang chờ duyệt",
      approved: "Đã duyệt",
      rejected: "Bị từ chối",
    };
    return (
      <span
        className={`px-3 py-1 rounded-full text-sm font-medium ${
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
        <Loader2 className="h-8 w-8 animate-spin text-emerald-600" />
      </div>
    );
  }

  return (
    <div className="min-h-screen theme-bg-primary py-8 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
          <div>
            <h1 className="text-3xl font-bold theme-text-primary">
              Hồ Sơ Nhà Cung Cấp
            </h1>
            <p className="mt-1 theme-text-secondary">
              Quản lý thông tin công ty và tài khoản
            </p>
          </div>
          <button
            onClick={() => setShowUserModal(true)}
            className="btn-primary flex items-center gap-2 px-6 py-3 rounded-lg"
          >
            <User className="h-5 w-5" />
            Thông Tin Người Dùng
          </button>
        </div>

        {/* Error Message */}
        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
            {error}
          </div>
        )}

        {/* Provider Information Card */}
        <div className="theme-bg-card rounded-2xl shadow-lg overflow-hidden">
          {/* Header with Logo */}
          <div className="relative h-48 bg-gradient-to-r from-emerald-500 to-teal-600">
            <div className="absolute -bottom-16 left-8">
              <div className="relative">
                {provider?.logoUrl ? (
                  <img
                    src={provider.logoUrl}
                    alt="Company Logo"
                    className="h-32 w-32 rounded-2xl border-4 border-white dark:border-gray-800 bg-white object-cover shadow-lg"
                  />
                ) : (
                  <div className="h-32 w-32 rounded-2xl border-4 border-white dark:border-gray-800 bg-white dark:bg-gray-700 flex items-center justify-center shadow-lg">
                    <Building2 className="h-16 w-16 text-gray-400" />
                  </div>
                )}
                <div className="absolute bottom-0 right-0 flex gap-1">
                  <button
                    onClick={() => logoInputRef.current?.click()}
                    className="p-2 bg-emerald-600 text-white rounded-full hover:bg-emerald-700 shadow-lg transition-colors"
                    title="Upload logo"
                  >
                    <Upload className="h-4 w-4" />
                  </button>
                  {provider?.logoUrl && (
                    <button
                      onClick={handleDeleteLogo}
                      className="p-2 bg-red-600 text-white rounded-full hover:bg-red-700 shadow-lg transition-colors"
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
                <h2 className="text-2xl font-bold theme-text-primary">
                  {provider?.companyName || "Chưa có tên công ty"}
                </h2>
                <p className="theme-text-secondary mt-1">
                  Mã số thuế: {provider?.taxCode || "—"}
                </p>
              </div>
              {!isEditingProvider ? (
                <button
                  onClick={handleEditProvider}
                  className="flex items-center gap-2 px-4 py-2 border theme-border rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                >
                  <Edit2 className="h-4 w-4" />
                  Chỉnh sửa
                </button>
              ) : (
                <div className="flex gap-2">
                  <button
                    onClick={handleSaveProvider}
                    disabled={loading}
                    className="flex items-center gap-2 px-4 py-2 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 transition-colors disabled:opacity-50"
                  >
                    {loading ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      <Save className="h-4 w-4" />
                    )}
                    Lưu
                  </button>
                  <button
                    onClick={handleCancelEditProvider}
                    disabled={loading}
                    className="flex items-center gap-2 px-4 py-2 border theme-border rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                  >
                    <X className="h-4 w-4" />
                    Hủy
                  </button>
                </div>
              )}
            </div>

            {/* Provider Details */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Company Name */}
              <div className="space-y-2">
                <label className="flex items-center gap-2 text-sm font-medium theme-text-secondary">
                  <Building2 className="h-4 w-4" />
                  Tên công ty
                </label>
                {isEditingProvider ? (
                  <input
                    type="text"
                    name="companyName"
                    value={providerForm.companyName || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  />
                ) : (
                  <p className="theme-text-primary">
                    {provider?.companyName || "—"}
                  </p>
                )}
              </div>

              {/* Tax Code */}
              <div className="space-y-2">
                <label className="flex items-center gap-2 text-sm font-medium theme-text-secondary">
                  <FileText className="h-4 w-4" />
                  Mã số thuế
                </label>
                {isEditingProvider ? (
                  <input
                    type="text"
                    name="taxCode"
                    value={providerForm.taxCode || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  />
                ) : (
                  <p className="theme-text-primary">
                    {provider?.taxCode || "—"}
                  </p>
                )}
              </div>

              {/* Address */}
              <div className="space-y-2 md:col-span-2">
                <label className="flex items-center gap-2 text-sm font-medium theme-text-secondary">
                  <MapPin className="h-4 w-4" />
                  Địa chỉ
                </label>
                {isEditingProvider ? (
                  <input
                    type="text"
                    name="address"
                    value={providerForm.address || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  />
                ) : (
                  <p className="theme-text-primary">
                    {provider?.address || "—"}
                  </p>
                )}
              </div>

              {/* Contact Email */}
              <div className="space-y-2">
                <label className="flex items-center gap-2 text-sm font-medium theme-text-secondary">
                  <Mail className="h-4 w-4" />
                  Email liên hệ
                </label>
                {isEditingProvider ? (
                  <input
                    type="email"
                    name="contactEmail"
                    value={providerForm.contactEmail || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  />
                ) : (
                  <p className="theme-text-primary">
                    {provider?.contactEmail || "—"}
                  </p>
                )}
              </div>

              {/* Contact Phone */}
              <div className="space-y-2">
                <label className="flex items-center gap-2 text-sm font-medium theme-text-secondary">
                  <Phone className="h-4 w-4" />
                  Số điện thoại
                </label>
                {isEditingProvider ? (
                  <input
                    type="tel"
                    name="contactPhone"
                    value={providerForm.contactPhone || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  />
                ) : (
                  <p className="theme-text-primary">
                    {provider?.contactPhone || "—"}
                  </p>
                )}
              </div>

              {/* Bank Account Number */}
              <div className="space-y-2">
                <label className="flex items-center gap-2 text-sm font-medium theme-text-secondary">
                  <CreditCard className="h-4 w-4" />
                  Số tài khoản ngân hàng
                </label>
                {isEditingProvider ? (
                  <input
                    type="text"
                    name="bankAccountNumber"
                    value={providerForm.bankAccountNumber || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  />
                ) : (
                  <p className="theme-text-primary">
                    {provider?.bankAccountNumber || "—"}
                  </p>
                )}
              </div>

              {/* Bank Name */}
              <div className="space-y-2">
                <label className="flex items-center gap-2 text-sm font-medium theme-text-secondary">
                  <Briefcase className="h-4 w-4" />
                  Tên ngân hàng
                </label>
                {isEditingProvider ? (
                  <input
                    type="text"
                    name="bankName"
                    value={providerForm.bankName || ""}
                    onChange={handleProviderChange}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  />
                ) : (
                  <p className="theme-text-primary">
                    {provider?.bankName || "—"}
                  </p>
                )}
              </div>

              {/* Description */}
              <div className="space-y-2 md:col-span-2">
                <label className="flex items-center gap-2 text-sm font-medium theme-text-secondary">
                  <FileText className="h-4 w-4" />
                  Mô tả công ty
                </label>
                {isEditingProvider ? (
                  <textarea
                    name="providerDescription"
                    value={providerForm.providerDescription || ""}
                    onChange={handleProviderChange}
                    rows={4}
                    className="w-full px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent resize-none"
                  />
                ) : (
                  <p className="theme-text-primary">
                    {provider?.providerDescription || "—"}
                  </p>
                )}
              </div>

              {/* Rating & Dates */}
              <div className="space-y-2">
                <label className="text-sm font-medium theme-text-secondary">
                  Đánh giá trung bình
                </label>
                <p className="theme-text-primary text-lg font-semibold">
                  {provider?.ratingOverall
                    ? `${provider.ratingOverall.toFixed(2)} ⭐`
                    : "Chưa có đánh giá"}
                </p>
              </div>

              <div className="space-y-2">
                <label className="flex items-center gap-2 text-sm font-medium theme-text-secondary">
                  <Calendar className="h-4 w-4" />
                  Ngày tạo
                </label>
                <p className="theme-text-primary">
                  {formatDate(provider?.createdAt)}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* User Modal */}
      {showUserModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="theme-bg-card rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="sticky top-0 theme-bg-card border-b theme-border px-6 py-4 flex justify-between items-center">
              <h2 className="text-xl font-bold theme-text-primary">
                Thông Tin Người Dùng
              </h2>
              <button
                onClick={() => {
                  setShowUserModal(false);
                  handleCancelEditUser();
                }}
                className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
              >
                <X className="h-5 w-5" />
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
                  <div className="h-32 w-32 rounded-full border-4 theme-border bg-gray-100 dark:bg-gray-700 flex items-center justify-center">
                    <User className="h-16 w-16 text-gray-400" />
                  </div>
                )}
                <div className="flex gap-2">
                  <button
                    onClick={() => avatarInputRef.current?.click()}
                    className="px-4 py-2 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 transition-colors flex items-center gap-2"
                  >
                    <Upload className="h-4 w-4" />
                    Upload Avatar
                  </button>
                  {user?.avatarUrl && (
                    <button
                      onClick={handleDeleteAvatar}
                      className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors flex items-center gap-2"
                    >
                      <Trash2 className="h-4 w-4" />
                      Xóa
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
                  className="w-full flex items-center justify-center gap-2 px-4 py-2 border theme-border rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                >
                  <Edit2 className="h-4 w-4" />
                  Chỉnh sửa thông tin
                </button>
              )}

              {/* User Details */}
              <div className="space-y-4">
                {/* Full Name */}
                <div className="space-y-2">
                  <label className="text-sm font-medium theme-text-secondary">
                    Họ và tên
                  </label>
                  {isEditingUser ? (
                    <input
                      type="text"
                      name="fullName"
                      value={userForm.fullName || ""}
                      onChange={handleUserChange}
                      className="w-full px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                    />
                  ) : (
                    <p className="theme-text-primary">
                      {user?.fullName || "—"}
                    </p>
                  )}
                </div>

                {/* Email */}
                <div className="space-y-2">
                  <label className="text-sm font-medium theme-text-secondary">
                    Email
                  </label>
                  <p className="theme-text-primary">{user?.email || "—"}</p>
                  <p className="text-xs theme-text-secondary">
                    (Email không thể thay đổi)
                  </p>
                </div>

                {/* Phone Number */}
                <div className="space-y-2">
                  <label className="text-sm font-medium theme-text-secondary">
                    Số điện thoại
                  </label>
                  {isEditingUser ? (
                    <input
                      type="tel"
                      name="phoneNumber"
                      value={userForm.phoneNumber || ""}
                      onChange={handleUserChange}
                      className="w-full px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                    />
                  ) : (
                    <p className="theme-text-primary">
                      {user?.phoneNumber || "—"}
                    </p>
                  )}
                </div>

                {/* Date of Birth */}
                <div className="space-y-2">
                  <label className="text-sm font-medium theme-text-secondary">
                    Ngày sinh
                  </label>
                  {isEditingUser ? (
                    <input
                      type="date"
                      name="dateOfBirth"
                      value={userForm.dateOfBirth || ""}
                      onChange={handleUserChange}
                      className="w-full px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                    />
                  ) : (
                    <p className="theme-text-primary">
                      {formatDate(user?.dateOfBirth)}
                    </p>
                  )}
                </div>

                {/* Gender */}
                <div className="space-y-2">
                  <label className="text-sm font-medium theme-text-secondary">
                    Giới tính
                  </label>
                  {isEditingUser ? (
                    <select
                      name="gender"
                      value={userForm.gender || ""}
                      onChange={handleUserChange}
                      className="w-full px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                    >
                      <option value="">Chọn giới tính</option>
                      <option value="male">Nam</option>
                      <option value="female">Nữ</option>
                      <option value="other">Khác</option>
                    </select>
                  ) : (
                    <p className="theme-text-primary">
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
                    <label className="text-sm font-medium theme-text-secondary">
                      Vai trò
                    </label>
                    <p className="theme-text-primary capitalize">
                      {user?.accountRole || "—"}
                    </p>
                  </div>
                  <div className="space-y-1">
                    <label className="text-sm font-medium theme-text-secondary">
                      Trạng thái
                    </label>
                    <p className="theme-text-primary capitalize">
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
                    className="flex-1 flex items-center justify-center gap-2 px-4 py-3 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 transition-colors disabled:opacity-50"
                  >
                    {loading ? (
                      <Loader2 className="h-5 w-5 animate-spin" />
                    ) : (
                      <Save className="h-5 w-5" />
                    )}
                    Lưu thay đổi
                  </button>
                  <button
                    onClick={handleCancelEditUser}
                    disabled={loading}
                    className="px-6 py-3 border theme-border rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                  >
                    Hủy
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
              <p className="text-center font-medium">{successMessage}</p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ProfileProviderPage;
