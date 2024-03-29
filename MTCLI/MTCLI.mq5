//+------------------------------------------------------------------+
//|                                                      MTCLI.mq5 |
//|                                     Copyright 2021, Valmir França |
//|                                       https://www.mql5.com/pt/users/vfranca |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Valmir França"
#property link      "https://www.mql5.com/pt/users/vfranca"
#property version   "2.00"
#property indicator_chart_window
//+------------------------------------------------------------------+
//--- Arqivos incluídos
#include "MTCLI.mqh"
//--- input parameters
input int InpTimer=1; // Tempo de atualização
input int InpBars=1000; // Quantidade de barras
//---
#property indicator_buffers 3 // bufers do indicador
//---//--- variáveis
int copied;
MqlRates rates[];
//---
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Exporta CSV dos timeframes
   EventSetTimer(InpTimer);
   GeraFile(Period(), Period());
//--- indicator buffers mapping
// SetIndexBuffer(0,m20,INDICATOR_DATA); //bufer m20
// SetIndexBuffer(1,m50,INDICATOR_DATA); //bufer m50
// SetIndexBuffer(2,m200,INDICATOR_DATA); //bufer m200
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
//--- Exporta os timeframes
   GeraFile(Period(), Period());
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
//| Função que exporta em CSV |
//+------------------------------------------------------------------+
void GeraFile(ENUM_TIMEFRAMES timeframes, string tile)
  {
   int FILE = FileOpen(Symbol() + Split(_Period) +".csv", FILE_WRITE | FILE_TXT);
   if(FILE != INVALID_HANDLE)
     {
      int copy = CopyRates(Symbol(), timeframes, TimeTradeServer(), InpBars, rates);
      for(int i = 1; i < copy; i++)
        {
         FileWrite(FILE,
                   rates[i].time, ",",
                   rates[i].open, ",",
                   rates[i].high, ",",
                   rates[i].low, ",",
                   rates[i].close, ",",
                   rates[i].tick_volume, ",",
                   rates[i].real_volume);
        }//end for
     }
   else
     {
      Print("Erro ao abrir arquivo, arquivo pode já estar aberto!");
     }
//---
   FileClose(FILE);
  } //end function ExportaCSV
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
