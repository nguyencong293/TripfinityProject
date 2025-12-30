import React from "react";
import {
  HelpCircle,
  Mail,
  Phone,
  MessageCircle,
  Clock,
  MapPin,
  ExternalLink,
  Book,
  AlertCircle,
  FileText,
} from "lucide-react";
import { useLanguage } from "../hooks/useLanguage";

const SupportPage: React.FC = () => {
  const { t } = useLanguage();

  const contactMethods = [
    {
      icon: Mail,
      title: t("support_email_title"),
      description: t("support_email_description"),
      value: "support@tripfinity.com",
      action: "mailto:support@tripfinity.com",
    },
    {
      icon: Phone,
      title: t("support_phone_title"),
      description: t("support_phone_description"),
      value: "+84 (028) 1234 5678",
      action: "tel:+842812345678",
    },
    {
      icon: MessageCircle,
      title: t("support_chat_title"),
      description: t("support_chat_description"),
      value: t("support_chat_available"),
      action: "/supplier/messages",
    },
  ];

  const faqs = [
    {
      question: t("support_faq_1_question"),
      answer: t("support_faq_1_answer"),
    },
    {
      question: t("support_faq_2_question"),
      answer: t("support_faq_2_answer"),
    },
    {
      question: t("support_faq_3_question"),
      answer: t("support_faq_3_answer"),
    },
    {
      question: t("support_faq_4_question"),
      answer: t("support_faq_4_answer"),
    },
  ];

  const resources = [
    {
      icon: Book,
      title: t("support_resource_guide"),
      description: t("support_resource_guide_desc"),
    },
    {
      icon: FileText,
      title: t("support_resource_docs"),
      description: t("support_resource_docs_desc"),
    },
    {
      icon: AlertCircle,
      title: t("support_resource_tips"),
      description: t("support_resource_tips_desc"),
    },
  ];

  return (
    <div className="max-w-6xl mx-auto px-6 py-8">
      {/* Header */}
      <div className="text-center mb-12">
        <div className="w-16 h-16 rounded-full theme-bg-primary mx-auto mb-4 flex items-center justify-center">
          <HelpCircle className="w-8 h-8 theme-text-button" />
        </div>
        <h1 className="text-3xl font-bold theme-text-primary mb-2">
          {t("support_title")}
        </h1>
        <p className="text-lg theme-text-secondary">
          {t("support_subtitle")}
        </p>
      </div>

      {/* Contact Methods */}
      <div className="mb-12">
        <h2 className="text-2xl font-bold theme-text-primary mb-6">
          {t("support_contact_title")}
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {contactMethods.map((method, index) => (
            <a
              key={index}
              href={method.action}
              className="theme-bg-card border theme-border rounded-xl p-6 hover:shadow-lg transition-shadow group"
            >
              <div className="w-12 h-12 rounded-full theme-bg-secondary flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                <method.icon className="w-6 h-6 theme-text-primary" />
              </div>
              <h3 className="text-lg font-semibold theme-text-primary mb-2">
                {method.title}
              </h3>
              <p className="text-sm theme-text-secondary mb-3">
                {method.description}
              </p>
              <div className="flex items-center gap-2 text-sm font-medium theme-text-brand">
                <span>{method.value}</span>
                <ExternalLink className="w-4 h-4" />
              </div>
            </a>
          ))}
        </div>
      </div>

      {/* Working Hours & Location */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-12">
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-full theme-bg-secondary flex items-center justify-center">
              <Clock className="w-5 h-5 theme-text-primary" />
            </div>
            <h3 className="text-lg font-semibold theme-text-primary">
              {t("support_hours_title")}
            </h3>
          </div>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between theme-text-secondary">
              <span>{t("support_hours_weekday")}</span>
              <span className="font-medium theme-text-primary">8:00 - 20:00</span>
            </div>
            <div className="flex justify-between theme-text-secondary">
              <span>{t("support_hours_weekend")}</span>
              <span className="font-medium theme-text-primary">9:00 - 17:00</span>
            </div>
          </div>
        </div>

        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-full theme-bg-secondary flex items-center justify-center">
              <MapPin className="w-5 h-5 theme-text-primary" />
            </div>
            <h3 className="text-lg font-semibold theme-text-primary">
              {t("support_office_title")}
            </h3>
          </div>
          <p className="text-sm theme-text-secondary">
            {t("support_office_address")}
          </p>
        </div>
      </div>

      {/* FAQs */}
      <div className="mb-12">
        <h2 className="text-2xl font-bold theme-text-primary mb-6">
          {t("support_faq_title")}
        </h2>
        <div className="space-y-4">
          {faqs.map((faq, index) => (
            <details
              key={index}
              className="theme-bg-card border theme-border rounded-xl overflow-hidden group"
            >
              <summary className="px-6 py-4 cursor-pointer list-none flex items-center justify-between hover:theme-bg-secondary transition-colors">
                <span className="font-semibold theme-text-primary">
                  {faq.question}
                </span>
                <svg
                  className="w-5 h-5 theme-text-secondary group-open:rotate-180 transition-transform"
                  fill="none"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path d="M19 9l-7 7-7-7" />
                </svg>
              </summary>
              <div className="px-6 pb-4 theme-text-secondary">
                {faq.answer}
              </div>
            </details>
          ))}
        </div>
      </div>

      {/* Resources */}
      <div>
        <h2 className="text-2xl font-bold theme-text-primary mb-6">
          {t("support_resources_title")}
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {resources.map((resource, index) => (
            <div
              key={index}
              className="theme-bg-card border theme-border rounded-xl p-6"
            >
              <div className="w-12 h-12 rounded-full theme-bg-secondary flex items-center justify-center mb-4">
                <resource.icon className="w-6 h-6 theme-text-primary" />
              </div>
              <h3 className="text-lg font-semibold theme-text-primary mb-2">
                {resource.title}
              </h3>
              <p className="text-sm theme-text-secondary">
                {resource.description}
              </p>
            </div>
          ))}
        </div>
      </div>

      {/* Emergency Notice */}
      <div className="mt-12 theme-bg-card border-2 border-orange-500 rounded-xl p-6">
        <div className="flex items-start gap-4">
          <div className="w-12 h-12 rounded-full bg-orange-100 flex items-center justify-center flex-shrink-0">
            <AlertCircle className="w-6 h-6 text-orange-600" />
          </div>
          <div>
            <h3 className="text-lg font-semibold theme-text-primary mb-2">
              {t("support_emergency_title")}
            </h3>
            <p className="text-sm theme-text-secondary mb-3">
              {t("support_emergency_description")}
            </p>
            <a
              href="tel:+842812345678"
              className="inline-flex items-center gap-2 px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors font-medium"
            >
              <Phone className="w-4 h-4" />
              {t("support_emergency_call")}
            </a>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SupportPage;
