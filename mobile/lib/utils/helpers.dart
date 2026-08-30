class Helpers {
  static String formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)} K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'draft': return 'Draft';
      case 'submitted': return 'Submitted';
      case 'under_review': return 'Under Review';
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      case 'disbursed': return 'Disbursed';
      default: return status;
    }
  }

  static String partnerTypeLabel(String type) {
    switch (type) {
      case 'SCA': return 'SC Agency';
      case 'PSB': return 'Public Sector Bank';
      case 'RRB': return 'Regional Rural Bank';
      case 'NBFC-MFI': return 'Micro Finance Institution';
      default: return type;
    }
  }
}
