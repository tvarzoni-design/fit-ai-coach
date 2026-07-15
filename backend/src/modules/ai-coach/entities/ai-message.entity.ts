import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { AiConversation } from './ai-conversation.entity';

@Entity('ai_messages')
export class AiMessage {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'conversation_id' })
  conversationId: string;

  @Column({ length: 20, comment: 'user ou assistant' })
  sender: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ name: 'tokens_used', type: 'int', nullable: true })
  tokensUsed: number;

  @Column({ type: 'text', nullable: true, name: 'context_used' })
  contextUsed: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => AiConversation)
  @JoinColumn({ name: 'conversation_id' })
  conversation: AiConversation;
}
