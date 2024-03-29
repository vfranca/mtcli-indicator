//+------------------------------------------------------------------+
//|                                                      Mtcli.mq5 |
//|                                     Copyright 2021, Valmir França |
//|                                       https://github.com/vfranca/mtcli-indicator |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Valmir França"
#property link      "https://github.com/vfranca/mtcli-indicator"
#property version   "1.0"
#property indicator_chart_window
//+------------------------------------------------------------------+
//--- input parameters
input int Input_Timer = 10; // Intervalo das cotações
input int Input_Digits = 5; // Dígitos
input string Input_MN1 = "s"; // Inclui Mensal
input string Input_W1 = "s"; // Inclui semanal
input string Input_D1 = "s"; // Inclui diario
input string Input_H4 = "s"; // Inclui H4
input string Input_H1 = "s"; // Inclui H1
input string Input_M15 = "n"; // Inclui M15
input string Input_M5 = "n"; // Inclui M5
input int Input_Angle = 10; // inclinacao da media movel
input int Input_M20 = 1; // MME curta
input int Input_M50 = 1; // MME intermediaria
input int Input_M200 = 1; // MME longa 
//---
//---
#property indicator_buffers 3 // bufers do indicador
//---
//--- variáveis
int copied; 
int hnd_m20;
int hnd_m50;
int hnd_m200;
double m20[621];
double m50[621];
double m200[621];
MqlRates rates[];
//---
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- gera CSV dos timeframes
   EventSetTimer(Input_Timer);
   if (Input_MN1 == "s") GeraFile(PERIOD_MN1, "Monthly");
   if (Input_W1 == "s") GeraFile(PERIOD_W1, "Weekly");
   if (Input_D1 == "s") GeraFile(PERIOD_D1, "Daily");
   if (Input_H4 == "s") GeraFile(PERIOD_H4, "H4");
   if (Input_H1 == "s") GeraFile(PERIOD_H1, "H1");
   if (Input_M15 == "s") GeraFile(PERIOD_M15, "M15");
   if (Input_M5 == "s") GeraFile(PERIOD_M5, "M5");
//--- indicator buffers mapping
   SetIndexBuffer(0,m20,INDICATOR_DATA); //bufer m20
   SetIndexBuffer(1,m50,INDICATOR_DATA); //bufer m50
   SetIndexBuffer(2,m200,INDICATOR_DATA); //bufer m200
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| OnDenit function                                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- encerra o timer
   EventKillTimer();
//---
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- gera o CSV dos timeframes
   if (Input_MN1 == "s") GeraFile(PERIOD_MN1, "Monthly");
   if (Input_W1 == "s") GeraFile(PERIOD_W1, "Weekly");
   if (Input_D1 == "s") GeraFile(PERIOD_D1, "Daily");
   if (Input_H4 == "s") GeraFile(PERIOD_H4, "H4");
   if (Input_H1 == "s") GeraFile(PERIOD_H1, "H1");
   if (Input_M15 == "s") GeraFile(PERIOD_M15, "M15");
   if (Input_M5 == "s") GeraFile(PERIOD_M5, "M5");
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Função que gera os arquivos CSV |
//+------------------------------------------------------------------+
void GeraFile(ENUM_TIMEFRAMES timeframes, string tile)
  {
//---
   double m20[621];
   double m50[621];
   double m200[621];
//---
   hnd_m20 = iMA(_Symbol,timeframes, Input_M20, 0,MODE_EMA, PRICE_CLOSE); //Media movel de curto prazo
   hnd_m50 = iMA(_Symbol,timeframes, Input_M50, 0,MODE_EMA, PRICE_CLOSE); //Media movel de prazo intermediario
   hnd_m200 = iMA(_Symbol,timeframes, Input_M200, 0,MODE_EMA, PRICE_CLOSE); //Media movel de longo prazo
//---
   copied = CopyBuffer(hnd_m20, 0, 0, 620, m20);   // popula array com 10 elementos(candle) 
   if ( copied < 0 )
     { 
      Print("hnd_M20 não OK ");
      return;
     }
//---
   copied = CopyBuffer(hnd_m50, 0, 0, 620, m50);   // popula array com 10 elementos(candle) 
   if ( copied < 0 )
     { 
      Print("hnd_M50 não OK ");
      return;
     }
//---
   copied = CopyBuffer(hnd_m200, 0, 0, 620, m200);   // popula array com 10 elementos(candle) 
   if ( copied < 0 )
     { 
      Print("hnd_M200 não OK ");
      return;
     }
//---
   int FILE = FileOpen(Symbol() + tile +".csv", FILE_WRITE | FILE_TXT);
   if(FILE != INVALID_HANDLE)
     {
      int copy = CopyRates(Symbol(), timeframes, TimeTradeServer(), 610, rates);
      for(int i = 1; i < copy; i++)
        { 
//---
         string sM20 = "m20 flat";
         string sAngle20 = DoubleToString((MathAbs( m20[i] - m20[i-1])),Input_Digits);
         if(m20[i] > (m20[i-1]+Input_Angle) ) sM20 = "m20 up";
         if(m20[i] < (m20[i-1]-Input_Angle) ) sM20 = "m20 down" ;
         //---
         string sM50 = "m50 flat"; 
         string sAngle50 = DoubleToString((MathAbs( m50[i] - m50[i-1])),Input_Digits);
         if(m50[i] > (m50[i-1] +Input_Angle)) sM50 = "m50 up" ;
         if(m50[i] < (m50[i-1]-Input_Angle) ) sM50 = "m50 down" ;
         //---
         string sM200 = "m200 flat"; 
         string sAngle200 = DoubleToString((MathAbs( m200[i] - m200[i-1])),Input_Digits);
         if(m200[i] > (m200[i-1]+Input_Angle) ) sM200 = "m200 up" ; 
         if(m200[i] < (m200[i-1]-Input_Angle) ) sM200 = "m200 down" ;                 
         //---
         FileWrite(FILE, 
            rates[i].time, ",", 
            rates[i].open, ",", 
            rates[i].high, ",", 
            rates[i].low, ",", 
            rates[i].close, ",", 
            rates[i].tick_volume, ",", 
            rates[i].real_volume, ",", 
            m20[i], ",", 
            sM20+sAngle20, ",", 
            m50[i], ",", 
            sM50+sAngle50, ",", 
            m200[i], ",", 
            sM200+sAngle200);
        }//end for
     }
   else
     {
      Print("Erro ao abrir arquivo, arquivo pode já estar aberto!");
     }
//---
   FileClose(FILE);
  }
//+------------------------------------------------------------------+