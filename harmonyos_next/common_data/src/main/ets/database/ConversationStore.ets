export interface Conversation {
  id: string;
  title: string;
  updatedAt: number;
}

export interface MessageRecord {
  id: string;
  conversationId: string;
  role: string;
  content: string;
  thinking?: string;
  action?: string;
  timestamp: number;
}

export class ConversationStore {
  private conversations: Conversation[] = [];
  private messages: MessageRecord[] = [];

  async listConversations(): Promise<Conversation[]> {
    return [...this.conversations];
  }

  async createConversation(title: string = '新对话'): Promise<Conversation> {
    const conversation: Conversation = {
      id: `${Date.now()}-${Math.random().toString(16).slice(2)}`,
      title,
      updatedAt: Date.now()
    };
    this.conversations.push(conversation);
    return conversation;
  }

  async saveMessages(conversationId: string, records: MessageRecord[]): Promise<void> {
    this.messages = this.messages.filter(msg => msg.conversationId !== conversationId).concat(records);
  }

  async loadMessages(conversationId: string): Promise<MessageRecord[]> {
    return this.messages.filter(msg => msg.conversationId === conversationId);
  }
}
