import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseService {
  private readonly logger = new Logger(FirebaseService.name);
  private app: admin.app.App | null = null;

  constructor(private configService: ConfigService) {
    this.initializeApp();
  }

  private initializeApp() {
    const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
    const privateKey = this.configService.get<string>('FIREBASE_PRIVATE_KEY');
    const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');

    if (!projectId || !privateKey || !clientEmail || projectId.startsWith('your-') || privateKey.startsWith('your-')) {
      this.logger.warn('Firebase credentials not configured - push notifications disabled');
      this.app = null;
      return;
    }

    try {
      const serviceAccount = {
        type: 'service_account',
        project_id: projectId,
        private_key_id: this.configService.get<string>('FIREBASE_PRIVATE_KEY_ID'),
        private_key: privateKey.replace(/\\n/g, '\n'),
        client_email: clientEmail,
        client_id: this.configService.get<string>('FIREBASE_CLIENT_ID'),
        auth_uri: 'https://accounts.google.com/o/oauth2/auth',
        token_uri: 'https://oauth2.googleapis.com/token',
        auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
        client_x509_cert_url: this.configService.get<string>('FIREBASE_CLIENT_CERT_URL'),
      };

      this.app = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
      });

      this.logger.log('Firebase initialized successfully');
    } catch (error) {
      this.logger.error('Failed to initialize Firebase', error);
      this.app = null;
    }
  }

  async sendPushNotification(
    token: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<boolean> {
    if (!this.app) {
      this.logger.warn('Firebase not configured - push notification skipped');
      return false;
    }
    try {
      const message: admin.messaging.Message = {
        notification: {
          title,
          body,
        },
        token,
        data,
      };

      const response = await this.app.messaging().send(message);
      this.logger.log(`Notification sent successfully: ${response}`);
      return true;
    } catch (error) {
      this.logger.error('Failed to send notification', error);
      return false;
    }
  }

  async sendToTopic(
    topic: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<boolean> {
    if (!this.app) {
      this.logger.warn('Firebase not configured - topic notification skipped');
      return false;
    }
    try {
      const message: admin.messaging.Message = {
        notification: {
          title,
          body,
        },
        topic,
        data,
      };

      const response = await this.app.messaging().send(message);
      this.logger.log(`Notification sent to topic ${topic}: ${response}`);
      return true;
    } catch (error) {
      this.logger.error('Failed to send notification to topic', error);
      return false;
    }
  }

  async sendToMultipleTokens(
    tokens: string[],
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<{ success: number; failure: number }> {
    if (!this.app) {
      this.logger.warn('Firebase not configured - multicast skipped');
      return { success: 0, failure: tokens.length };
    }
    try {
      const message: admin.messaging.MulticastMessage = {
        notification: {
          title,
          body,
        },
        tokens,
        data,
      };

      const response = await this.app.messaging().sendEachForMulticast(message);
      this.logger.log(`Notifications sent: ${response.successCount} success, ${response.failureCount} failure`);
      
      return {
        success: response.successCount,
        failure: response.failureCount,
      };
    } catch (error) {
      this.logger.error('Failed to send notifications', error);
      return { success: 0, failure: tokens.length };
    }
  }

  async subscribeToTopic(tokens: string[], topic: string): Promise<void> {
    if (!this.app) return;
    try {
      await this.app.messaging().subscribeToTopic(tokens, topic);
      this.logger.log(`Tokens subscribed to topic ${topic}`);
    } catch (error) {
      this.logger.error('Failed to subscribe to topic', error);
    }
  }

  async unsubscribeFromTopic(tokens: string[], topic: string): Promise<void> {
    if (!this.app) return;
    try {
      await this.app.messaging().unsubscribeFromTopic(tokens, topic);
      this.logger.log(`Tokens unsubscribed from topic ${topic}`);
    } catch (error) {
      this.logger.error('Failed to unsubscribe from topic', error);
    }
  }
}
