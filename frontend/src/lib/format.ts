export function formatDateMMDDYYYY(dateInput: string | Date | null | undefined): string {
  if (!dateInput) return '';
  let d: Date;
  if (dateInput instanceof Date) {
    d = dateInput;
  } else if (typeof dateInput === 'string') {
    const str = dateInput.trim();
    if (/^\d{4}-\d{2}-\d{2}$/.test(str)) {
      const [y, m, day] = str.split('-').map((n) => Number(n));
      d = new Date(y, m - 1, day);
    } else {
      const parsed = new Date(str);
      if (isNaN(parsed.getTime())) return str;
      d = parsed;
    }
  } else {
    return '';
  }

  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  const yyyy = d.getFullYear();
  return `${mm}/${dd}/${yyyy}`;
}


