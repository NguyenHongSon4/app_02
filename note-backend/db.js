const low = require('lowdb');
const FileSync = require('lowdb/adapters/FileSync');
const adapter = new FileSync('db.json');
const db = low(adapter);

// Không cần khởi tạo lại dữ liệu mặc định vì file db.json đã có dữ liệu
// Chỉ cần đảm bảo db.json tồn tại và có cấu trúc hợp lệ
module.exports = db;