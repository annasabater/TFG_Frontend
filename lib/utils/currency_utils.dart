String getCurrencySymbol(String currency) {
  switch (currency) {
    case 'USD':
      return '\$'; // $
    case 'GBP':
      return '£'; // £
    case 'JPY':
      return '¥'; // ¥
    case 'CHF':
      return 'CHF';
    case 'CAD':
      return 'CA\$';
    case 'AUD':
      return 'A\$';
    case 'CNY':
      return 'CN¥';
    case 'HKD':
      return 'HK\$';
    case 'NZD':
      return 'NZ\$';
    case 'EUR':
    default:
      return '€';
  }
}

int getCurrencyDecimals(String currency) {
  switch (currency) {
    case 'JPY':
    case 'CNY':
      return 0;
    default:
      return 2;
  }
}
