const express = require('express');
const cors = require('cors');
const db = require('./db');
const { v4: uuidv4 } = require('uuid');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// Cấu hình multer để upload hình ảnh
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage });

// Tạo thư mục uploads nếu chưa có
if (!fs.existsSync('uploads')) {
  fs.mkdirSync('uploads');
}

// Serve file tĩnh (hình ảnh)
app.use('/uploads', express.static('uploads'));

// API: Lấy tất cả ghi chú
app.get('/api/notes', (req, res) => {
  const notes = db.get('notes').value();
  res.json(notes);
});

// API: Lấy ghi chú theo ID
app.get('/api/notes/:id', (req, res) => {
  const note = db.get('notes').find({ id: req.params.id }).value();
  if (note) {
    res.json(note);
  } else {
    res.status(404).json({ message: 'Ghi chú không tồn tại' });
  }
});

// API: Thêm ghi chú mới
app.post('/api/notes', (req, res) => {
  const { title, content, priority, tags, color } = req.body;
  const newNote = {
    id: uuidv4(),
    title,
    content,
    priority: priority || 1,
    createdAt: new Date().toISOString(),
    modifiedAt: new Date().toISOString(),
    tags: tags || null,
    color: color || '#FFFFFF',
    imagePath: null,
  };
  db.get('notes').push(newNote).write();
  res.status(201).json(newNote);
});

// API: Cập nhật ghi chú
app.put('/api/notes/:id', (req, res) => {
  const { title, content, priority, tags, color, imagePath } = req.body;
  const note = db.get('notes').find({ id: req.params.id });
  if (note.value()) {
    note.assign({
      title,
      content,
      priority: priority || note.value().priority,
      tags: tags || note.value().tags,
      color: color || note.value().color,
      imagePath: imagePath || note.value().imagePath,
      modifiedAt: new Date().toISOString(),
    }).write();
    res.json(note.value());
  } else {
    res.status(404).json({ message: 'Ghi chú không tồn tại' });
  }
});

// API: Xóa ghi chú
app.delete('/api/notes/:id', (req, res) => {
  const note = db.get('notes').remove({ id: req.params.id }).write();
  if (note.length > 0) {
    res.json({ message: 'Ghi chú đã được xóa' });
  } else {
    res.status(404).json({ message: 'Ghi chú không tồn tại' });
  }
});

// API: Lấy tất cả tài khoản
app.get('/api/accounts', (req, res) => {
  const accounts = db.get('accounts').value();
  res.json(accounts);
});

// API: Lấy tài khoản theo ID
app.get('/api/accounts/:id', (req, res) => {
  const account = db.get('accounts').find({ id: parseInt(req.params.id) }).value();
  if (account) {
    res.json(account);
  } else {
    res.status(404).json({ message: 'Tài khoản không tồn tại' });
  }
});

// API: Đăng nhập (kiểm tra username và password)
app.post('/api/login', (req, res) => {
  const { username, password } = req.body;
  const account = db.get('accounts').find({ username, password }).value();
  if (account) {
    account.lastLogin = new Date().toISOString();
    db.get('accounts').find({ id: account.id }).assign(account).write();
    res.json({ message: 'Đăng nhập thành công', account });
  } else {
    res.status(401).json({ message: 'Tên đăng nhập hoặc mật khẩu không đúng' });
  }
});

// API: Đăng ký tài khoản mới
app.post('/api/register', (req, res) => {
  const { username, password } = req.body;
  const existingAccount = db.get('accounts').find({ username }).value();
  if (existingAccount) {
    res.status(400).json({ message: 'Tên đăng nhập đã tồn tại' });
  } else {
    const newAccount = {
      id: db.get('accounts').size().value() + 1,
      userId: 1000 + db.get('accounts').size().value() + 1,
      username,
      password,
      status: 'active',
      lastLogin: new Date().toISOString(),
      createdAt: new Date().toISOString(),
    };
    db.get('accounts').push(newAccount).write();
    res.status(201).json(newAccount);
  }
});

// API: Upload hình ảnh
app.post('/api/upload', upload.single('image'), (req, res) => {
  if (req.file) {
    res.json({ imagePath: `/uploads/${req.file.filename}` });
  } else {
    res.status(400).json({ message: 'Lỗi khi upload hình ảnh' });
  }
});

// Chạy server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server chạy tại http://localhost:${PORT}`);
});