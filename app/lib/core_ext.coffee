# core math requirement for money calculations
Math.roundToFixed = (num, dec) -> Math.round(num*Math.pow(10, dec))/Math.pow(10,dec)
