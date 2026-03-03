class DateUtil{
  String formattedDate(DateTime selectedDate) {
    return "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
  }
}