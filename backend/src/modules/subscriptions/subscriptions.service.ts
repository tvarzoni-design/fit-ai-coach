import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Subscription } from './entities/subscription.entity';
import { StripeService } from './stripe.service';

@Injectable()
export class SubscriptionsService {
  private readonly logger = new Logger(SubscriptionsService.name);

  constructor(
    @InjectRepository(Subscription)
    private subscriptionRepository: Repository<Subscription>,
    private stripeService: StripeService,
  ) {}

  async getCurrent(userId: string): Promise<Subscription | null> {
    return this.subscriptionRepository.findOne({
      where: { userId, status: 'active' },
      order: { createdAt: 'DESC' },
    });
  }

  async create(userId: string, data: Partial<Subscription>): Promise<Subscription> {
    const subscription = this.subscriptionRepository.create({ userId, ...data });
    return this.subscriptionRepository.save(subscription);
  }

  async cancel(userId: string): Promise<void> {
    const subscription = await this.getCurrent(userId);
    if (subscription) {
      // Cancel on Stripe
      if (subscription.stripeSubscriptionId) {
        await this.stripeService.cancelSubscription(subscription.stripeSubscriptionId);
      }
      
      subscription.status = 'cancelled';
      subscription.autoRenew = false;
      await this.subscriptionRepository.save(subscription);
    }
  }

  async createCheckoutSession(
    userId: string,
    priceId: string,
    successUrl: string,
    cancelUrl: string,
  ): Promise<{ sessionId: string; url: string }> {
    try {
      // Get or create Stripe customer
      const customer = await this.stripeService.createCustomer(
        'user@example.com', // TODO: Get from user entity
        'User Name', // TODO: Get from user entity
      );

      // Create checkout session
      const session = await this.stripeService.createCheckoutSession(
        customer.id,
        priceId,
        successUrl,
        cancelUrl,
      );

      // Save subscription record
      await this.create(userId, {
        stripeCustomerId: customer.id,
        stripeSubscriptionId: session.subscription as string,
        status: 'pending',
        planId: priceId,
      });

      return {
        sessionId: session.id,
        url: session.url || '',
      };
    } catch (error) {
      this.logger.error('Failed to create checkout session', error);
      throw error;
    }
  }

  async handleWebhookEvent(event: any): Promise<void> {
    switch (event.type) {
      case 'checkout.session.completed':
        await this.handleCheckoutComplete(event.data.object);
        break;
      case 'invoice.paid':
        await this.handleInvoicePaid(event.data.object);
        break;
      case 'invoice.payment_failed':
        await this.handlePaymentFailed(event.data.object);
        break;
      case 'customer.subscription.deleted':
        await this.handleSubscriptionDeleted(event.data.object);
        break;
      default:
        this.logger.log(`Unhandled event type: ${event.type}`);
    }
  }

  private async handleCheckoutComplete(session: any): Promise<void> {
    const subscription = await this.subscriptionRepository.findOne({
      where: { stripeSubscriptionId: session.subscription },
    });

    if (subscription) {
      subscription.status = 'active';
      subscription.currentPeriodStart = new Date(session.subscription.current_period_start * 1000);
      subscription.currentPeriodEnd = new Date(session.subscription.current_period_end * 1000);
      await this.subscriptionRepository.save(subscription);
    }
  }

  private async handleInvoicePaid(invoice: any): Promise<void> {
    const subscription = await this.subscriptionRepository.findOne({
      where: { stripeSubscriptionId: invoice.subscription },
    });

    if (subscription) {
      subscription.currentPeriodStart = new Date(invoice.period_start * 1000);
      subscription.currentPeriodEnd = new Date(invoice.period_end * 1000);
      await this.subscriptionRepository.save(subscription);
    }
  }

  private async handlePaymentFailed(invoice: any): Promise<void> {
    const subscription = await this.subscriptionRepository.findOne({
      where: { stripeSubscriptionId: invoice.subscription },
    });

    if (subscription) {
      subscription.status = 'past_due';
      await this.subscriptionRepository.save(subscription);
    }
  }

  private async handleSubscriptionDeleted(subscriptionData: any): Promise<void> {
    const subscription = await this.subscriptionRepository.findOne({
      where: { stripeSubscriptionId: subscriptionData.id },
    });

    if (subscription) {
      subscription.status = 'cancelled';
      await this.subscriptionRepository.save(subscription);
    }
  }

  async getPlans(): Promise<any[]> {
    return [
      { 
        id: 'free', 
        name: 'Gratuito', 
        price: 0, 
        features: ['Treinos básicos', 'Chat IA limitado'],
        stripePriceId: null,
      },
      { 
        id: 'premium_monthly', 
        name: 'Premium Mensal', 
        price: 29.90, 
        features: ['IA ilimitada', 'Nutrição', 'Relatórios'],
        stripePriceId: 'price_monthly_premium',
      },
      { 
        id: 'premium_yearly', 
        name: 'Premium Anual', 
        price: 199.90, 
        features: ['IA ilimitada', 'Nutrição', 'Relatórios', '2 meses grátis'],
        stripePriceId: 'price_yearly_premium',
      },
    ];
  }

  async isPremium(userId: string): Promise<boolean> {
    const subscription = await this.getCurrent(userId);
    return subscription?.status === 'active';
  }
}
