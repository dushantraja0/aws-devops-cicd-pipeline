const express = require('express');
const healthRoute = require('./routes/health');
const tasksRoute = require('./routes/tasks');

const app = express();
const PORT = process.env.PORT || 80;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    message: 'Task Manager API is running',
    docs: '/tasks, /health'
  });
});

app.use('/', healthRoute);
app.use('/', tasksRoute);

// Only start server if this file is run directly (not when imported for testing)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
  });
}

module.exports = app;
