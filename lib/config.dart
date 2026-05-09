class APIConfig {
  static const baseURL = "https://portfolio-api.achiket.site";
  static const portfolio = '$baseURL/api/v1/data/portfolio';
  static const blogList = '$baseURL/api/v1/data/blogs';
  static getBlog(String slug) => "$baseURL/api/v1/data/blogs/$slug";
}
