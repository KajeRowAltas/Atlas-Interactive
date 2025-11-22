module.exports = {
  safeJsonParse: (input, fallback = {}) => {
    try {
      return JSON.parse(input);
    } catch (error) {
      return fallback;
    }
  },
  buildChatRecord: ({ sessionId, userMessage, response, analysis }) => ({
    sessionId,
    message: userMessage,
    response,
    analysis,
    createdAt: new Date(),
  }),
};
