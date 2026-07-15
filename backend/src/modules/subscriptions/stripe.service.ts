import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Stripe from 'stripe';

@Injectable()
export class StripeService {
  private readonly logger = new Logger(StripeService.name);
  private stripe: Stripe | null = null;
  private configured = false;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('STRIPE_SECRET_KEY') || '';
    if (!apiKey || apiKey === 'your-stripe-secret-key') {
      this.logger.warn('Stripe not configured - payments disabled');
      return;
    }
    this.stripe = new Stripe(apiKey, { apiVersion: '2023-10-16' });
    this.configured = true;
    this.logger.log('Stripe initialized successfully');
  }

  private getStripe(): Stripe {
    if (!this.configured || !this.stripe) {
      throw new Error('Stripe não configurado. Adicione STRIPE_SECRET_KEY no .env');
    }
    return this.stripe;
  }

  async createCustomer(email: string, name: string): Promise<Stripe.Customer> {
    const stripe = this.getStripe();
    try {
      return await stripe.customers.create({ email, name });
    } catch (error) {
      this.logger.error('Failed to create Stripe customer', error);
      throw error;
    }
  }

  async createSubscription(
    customerId: string,
    priceId: string,
  ): Promise<Stripe.Subscription> {
    const stripe = this.getStripe();
    try {
      return await stripe.subscriptions.create({
        customer: customerId,
        items: [{ price: priceId }],
        payment_behavior: 'default_incomplete',
        expand: ['latest_invoice.payment_intent'],
      });
    } catch (error) {
      this.logger.error('Failed to create subscription', error);
      throw error;
    }
  }

  async cancelSubscription(subscriptionId: string): Promise<Stripe.Subscription> {
    const stripe = this.getStripe();
    try {
      return await stripe.subscriptions.cancel(subscriptionId);
    } catch (error) {
      this.logger.error('Failed to cancel subscription', error);
      throw error;
    }
  }

  async createPaymentIntent(
    amount: number,
    currency: string,
    customerId: string,
  ): Promise<Stripe.PaymentIntent> {
    const stripe = this.getStripe();
    try {
      return await stripe.paymentIntents.create({
        amount,
        currency,
        customer: customerId,
      });
    } catch (error) {
      this.logger.error('Failed to create payment intent', error);
      throw error;
    }
  }

  async createCheckoutSession(
    customerId: string,
    priceId: string,
    successUrl: string,
    cancelUrl: string,
  ): Promise<Stripe.Checkout.Session> {
    const stripe = this.getStripe();
    try {
      return await stripe.checkout.sessions.create({
        customer: customerId,
        payment_method_types: ['card'],
        line_items: [{ price: priceId, quantity: 1 }],
        mode: 'subscription',
        success_url: successUrl,
        cancel_url: cancelUrl,
      });
    } catch (error) {
      this.logger.error('Failed to create checkout session', error);
      throw error;
    }
  }

  async getSubscription(subscriptionId: string): Promise<Stripe.Subscription> {
    const stripe = this.getStripe();
    try {
      return await stripe.subscriptions.retrieve(subscriptionId);
    } catch (error) {
      this.logger.error('Failed to get subscription', error);
      throw error;
    }
  }

  async getCustomerSubscriptions(
    customerId: string,
  ): Promise<Stripe.Subscription[]> {
    const stripe = this.getStripe();
    try {
      const subscriptions = await stripe.subscriptions.list({
        customer: customerId,
      });
      return subscriptions.data;
    } catch (error) {
      this.logger.error('Failed to get customer subscriptions', error);
      throw error;
    }
  }

  async handleWebhook(
    payload: Buffer,
    signature: string,
  ): Promise<Stripe.Event> {
    const stripe = this.getStripe();
    try {
      const webhookSecret = this.configService.get<string>('STRIPE_WEBHOOK_SECRET') || '';
      return stripe.webhooks.constructEvent(
        payload,
        signature,
        webhookSecret,
      );
    } catch (error) {
      this.logger.error('Failed to handle webhook', error);
      throw error;
    }
  }
}
