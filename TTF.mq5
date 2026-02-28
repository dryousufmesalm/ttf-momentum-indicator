//+------------------------------------------------------------------+
//|                                            TTF.mq5 |
//|                                    Copyright 2025, Yousuf Mesalm. |
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Yousuf Mesalm. www.yousufmesalm.com | WhatsApp +201006179048"
#property link      "https://www.yousufmesalm.com"
#property version   "1.00"
#property indicator_chart_window
//---- indicators setting
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_style1 DRAW_ARROW
#property indicator_style2 DRAW_ARROW
#property indicator_color1 Red
#property indicator_color2 Green
//---- input parameters
input int       TTFbars=12;
input int       t3_period=6;
input double    b=1.618;
//---- buffers
double ExtMapBuffer1[],ExtMapBuffer2[];
double b2,b3,c1,c2,c3,c4,e1,e2,e3,e4,e5,e6,w1,w2,TTF,r;
double HighestHighRecent,HighestHighOlder,LowestLowRecent,LowestLowOlder;
double BuyPower,SellPower;
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---- indicators
   SetIndexBuffer(0,ExtMapBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtMapBuffer2,INDICATOR_DATA);
   ArraySetAsSeries(ExtMapBuffer1,true);
   ArraySetAsSeries(ExtMapBuffer2,true);
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+

   b2=b*b;
   b3=b2*b;
   c1=-b3;
   c2=(3*(b2+b3));
   c3=-3*(2*b2+b+b3);
   c4=(1+3*b+b3+3*b2);
   r=t3_period;
   if(r<1)
      r=1;
   r=1+0.5*(r-1);
   w1=2/(r + 1);
   w2=1 - w1;
//
   e1=0;
   e2=0;
   e3=0;
   e4=0;
   e5=0;
   e6=0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   if(rates_total < TTFbars + 2) return(0);
   int limit = (prev_calculated > 0) ? (rates_total - prev_calculated + 1) : (rates_total - 1);
   limit = MathMin(limit, rates_total - 1 - TTFbars - 1);
   if(limit <= 0) return(rates_total);
   for(int i = limit; i >= 0; i--)
     {
      int startRecent = MathMax(0, i - TTFbars + 1);
      int startOlder  = MathMin(rates_total - 1, i + 1);
      int sh_high_recent = iHighest(_Symbol, _Period, MODE_HIGH, startRecent, TTFbars);
      int sh_high_older  = iHighest(_Symbol, _Period, MODE_HIGH, startOlder,  TTFbars);
      int sh_low_recent  = iLowest(_Symbol,  _Period, MODE_LOW,  startRecent, TTFbars);
      int sh_low_older   = iLowest(_Symbol,  _Period, MODE_LOW,  startOlder,  TTFbars);
      HighestHighRecent = high[rates_total - 1 - sh_high_recent];
      HighestHighOlder  = high[rates_total - 1 - sh_high_older];
      LowestLowRecent   = low[rates_total - 1 - sh_low_recent];
      LowestLowOlder    = low[rates_total - 1 - sh_low_older];
      BuyPower  = HighestHighRecent - LowestLowOlder;
      SellPower = HighestHighOlder - LowestLowRecent;
      TTF = (BuyPower + SellPower != 0) ? (BuyPower - SellPower) / (0.5 * (BuyPower + SellPower)) * 100 : 0;
      e1 = w1 * TTF + w2 * e1;
      e2 = w1 * e1 + w2 * e2;
      e3 = w1 * e2 + w2 * e3;
      e4 = w1 * e3 + w2 * e4;
      e5 = w1 * e4 + w2 * e5;
      e6 = w1 * e5 + w2 * e6;
      TTF = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3;
      double hiVal = high[rates_total - 1 - i];
      double loVal = low[rates_total - 1 - i];
      if(TTF <= -100)
        {
         ExtMapBuffer1[i] = hiVal + 4 * _Point;
         ExtMapBuffer2[i] = 0;
        }
      else if(TTF >= 100)
        {
         ExtMapBuffer1[i] = 0;
         ExtMapBuffer2[i] = loVal - 4 * _Point;
        }
      else
        {
         ExtMapBuffer1[i] = 0;
         ExtMapBuffer2[i] = 0;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
