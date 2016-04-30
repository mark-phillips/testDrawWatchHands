//!
//! Copyright 2015 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

using Toybox.ActivityMonitor as Act;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

//! This implements an analog watch face
//! Original design by Austen Harbour
class TestbedFace extends Ui.WatchFace
{
    var font;
    var background;
    var deviceName;
    var highPowerMode = false;
    var deg2rad = Math.PI/180;
    var CLOCKWISE = -1;
    var COUNTERCLOCKWISE = 1;
    var moveBarLevel = -1 ;
    var radius = 0;
    var debug = false;
    var switch_date = false;

    //! Constructor
    function initialize()
    {
    }

    //! Load resources
    function onLayout()
    {
        font = Ui.loadResource(Rez.Fonts.id_font_black_diamond);
        background = Ui.loadResource(Rez.Drawables.background_id);
        deviceName = Ui.loadResource(Rez.Strings.id_device_type);
    }

    function onShow()
    {
    }

    //! Nothing to do when going away
    function onHide()
    {
    }
    function drawTriangle(dc, angle, width, inner, length)
    {
        // Map out the coordinates 
        var coords = [ [0,-inner], [-(width/2), -length], [width/2, -length] ];
        var result = new [3];
        var centerX = radius;
        var centerY = radius;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 3; i += 1)
        {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [ centerX+x, centerY+y];
        }

        // Draw the polygon
        dc.fillPolygon(result);
    }

    function drawLineFromMin(dc, min, width, inner, length)
    {
        var angle = (min / 60.0) * Math.PI * 2;
        // Map out the coordinates 
        var coords = [ [0,-inner], [0, -length] ];
        var result = new [2];
        var centerX = radius;
        var centerY = radius;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 2; i += 1)
        {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [ centerX+x, centerY+y];
        }

        // Draw the Line
        dc.drawLine(result[0][0],result[0][1],result[1][0],result[1][1]);
    }

    function drawBlockFromMin(dc, min, width, inner, length)
    {
        var angle = (min / 60.0) * Math.PI * 2;
        drawBlock(dc, angle, width, inner, length);
    }
    function drawBlock(dc, angle, width, inner, length)
    {
        // Map out the coordinates 
        var coords = [ [-(width/2),-inner], [-(width/2), -length], [width/2, -length], [width/2, -inner] ];
        var result = new [4];
        var centerX = radius;
        var centerY = radius;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 4; i += 1)
        {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [ centerX+x, centerY+y];
        }

        // Draw the polygon
        dc.fillPolygon(result);
    }

    //! Draw the Hour hand
    function drawHourHand(dc, min)
    {
        var cos = Math.cos(min);
        var sin = Math.sin(min);
        var centerX = radius;
        var centerY = radius;

        // Map out the coordinates of the watch hand
        var length = 50;
        var width = 12;
        var start = 16;

        dc.setColor(Gfx.COLOR_DK_GRAY,Gfx.COLOR_BLACK);
        drawBlock(dc, min, width, start, length);
        // Draw the base Triangle
        drawTriangle(dc, min, width, 0, start);
        dc.setColor(Gfx.COLOR_WHITE,Gfx.COLOR_WHITE);
        drawBlock(dc, min, width/3, start , length);
        //
        // Draw the Circle
        //var circumf = 10;
        //var circle_start = length-circumf*1.4;
        //var x = (-1f * cos) - (-circle_start * sin);
        //var y = (1f* sin) + (-circle_start*cos);
        ////dc.setColor(Gfx.COLOR_DK_GRAY,Gfx.COLOR_LT_GRAY);
        //dc.fillCircle(centerX+x, centerY+y,  circumf );
        //dc.fillCircle(centerX+x, centerY+y, circumf-2 );


        // Draw the arrowhead
        dc.setColor(Gfx.COLOR_DK_GRAY,Gfx.COLOR_LT_GRAY);
        drawTriangle(dc, min, width+8, length+20, length);
        // Draw the Trimin
        dc.setColor(Gfx.COLOR_WHITE,Gfx.COLOR_WHITE);
        drawTriangle(dc, min, width-2 , length+12, length+3);

    }

    function drawMinuteHand(dc, min)
    {
        var length = 74;
        var width = 10;
        var start = 20;
        dc.setColor(Gfx.COLOR_DK_GRAY,Gfx.COLOR_LT_GRAY);
        drawBlock(dc, min, width, 20, length);
        // Draw the base Triangle
        drawTriangle(dc, min, width, 0, start);

        // Fill the interior
        dc.setColor(Gfx.COLOR_WHITE,Gfx.COLOR_WHITE);
        drawBlock(dc, min, width/2, start, length);

        // Draw the Triangle
        dc.setColor(Gfx.COLOR_DK_GRAY,Gfx.COLOR_LT_GRAY);
        drawTriangle(dc, min, width*2 , length+width*2, length);
        // Draw the Triangle
        dc.setColor(Gfx.COLOR_WHITE,Gfx.COLOR_WHITE);
        drawTriangle(dc, min, width, length+13, length+3);
    }

    function drawSecondHand(dc,min)
    {
        var length = 84;
        var width =  6;
        var start = 10;
        dc.setColor(Gfx.COLOR_DK_GRAY,Gfx.COLOR_LT_GRAY);
        drawBlock(dc, min, width, 20, length);
        // Draw the base Triangle
        drawTriangle(dc, min, width, 0, 20);

        // Fill the interior
        dc.setColor(Gfx.COLOR_WHITE,Gfx.COLOR_WHITE);
        drawBlock(dc, min, width/3, start, length);

        // Draw the Triangle
        dc.setColor(Gfx.COLOR_DK_GRAY,Gfx.COLOR_LT_GRAY);
        drawTriangle(dc, min, width*2 , length+width*2, length);
        // Draw the Triangle
        dc.setColor(Gfx.COLOR_WHITE,Gfx.COLOR_WHITE);
        drawTriangle(dc, min, width, length+12, length+3);
    }


    // Draw minute marker
    //  https://forums.garmin.com/showthread.php?301499-How-to-draw-a-ring-like-this&highlight=draw
    function drawMinuteMarks(dc ) 
    {
        var inset = -10;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE); 
        drawWedge(dc,0,2,inset,8);
        drawWedge(dc,5,2,inset,25);
        drawWedge(dc,10,2,inset,25);
        drawWedge(dc,15,2,inset,8);
        drawWedge(dc,20,2,inset,25);
        drawWedge(dc,25,2,inset,25);
        drawWedge(dc,30,2,inset,8);
        drawWedge(dc,35,2,inset,25);
        drawWedge(dc,40,2,inset,25);
        drawWedge(dc,45,2,inset,8);
        drawWedge(dc,50,2,inset,25);
        drawWedge(dc,55,2,inset,25);
        var length = 6;
        var end = dc.getHeight()/2 - length;
        var start = end - length;
        var c;
        for (c=0; c<5; c++) { drawLineFromMin(dc,1+c,2,radius-6 ,radius); } 
        for (c=0; c<5; c++) { drawLineFromMin(dc,6+c,2,radius-6,radius); } 
        for (c=0; c<5; c++) { drawLineFromMin(dc,11+c,2,radius-6,radius); } 
        for (c=0; c<5; c++) { drawLineFromMin(dc,16+c,2,radius-6,radius); } 
        for (c=0; c<5; c++) { drawLineFromMin(dc,21+c,2,radius-6,radius); } 
        for (c=0; c<5; c++) { drawLineFromMin(dc,26+c,2,radius-6,radius); } 
        for (c=0; c<5; c++) { drawLineFromMin(dc,31+c,2,radius-6,radius); } 
        for (c=0; c<5; c++) { drawLineFromMin(dc,36+c,2,radius-6,radius); } 
        for (c=0; c<5; c++) { drawLineFromMin(dc,41+c,2,radius-6,radius); } 
        for (c=0; c<5; c++) { drawLineFromMin(dc,46+c,2,radius-6,radius); } 
        for (c=0; c<5; c++) { drawLineFromMin(dc,51+c,2,radius-6,radius); } 
        for (c=0; c<5; c++) { drawLineFromMin(dc,56+c,2,radius-6,radius); } 
    }

    function drawTwelve(dc) 
    {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE); 
        drawTriangle(dc, 0, 24, radius-45, radius-12);
        if (Sys.getDeviceSettings().phoneConnected) 
        {
            dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
            drawTriangle(dc, 0,  12, radius-38, radius-16 );
        }
        else
        {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
            dc.fillCircle(radius, 22, 6);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(radius, 8 , Gfx.FONT_SMALL, "-", Gfx.TEXT_JUSTIFY_CENTER); // 
        }
    }


    function drawWedge(dc, minute ,tickwidth, inset, length ) 
    {
        var end = radius-length;
        var xx, xx2, yy, yy2,kxx,kyy,kxx2,kyy2, winkel;
        winkel = 180 +minute * -6;
        var tickwidth2=tickwidth;
        var tickwidth3=1;
        var winkelPI2 = Math.PI*(winkel-tickwidth2)/180;
        var winkelPI3 = Math.PI*(winkel+tickwidth3)/180;
        var cosPI2 = Math.cos(winkelPI2);
        var cosPI3 = Math.cos(winkelPI3);
        var sinPI2 = Math.sin(winkelPI2);
        var sinPI3 = Math.sin(winkelPI3);
        yy  = 1*radius * (1+cosPI2 );
        yy2 = 1*radius * (1+cosPI3);  
        xx  = 1* radius * (1+sinPI2 );
        xx2 = 1* radius * (1+sinPI3); 
        kyy  = 1*radius + end * (cosPI2 ); 
        kyy2 = 1*radius + end * (cosPI3);  
        kxx  = 1* radius + end * (sinPI2);
        kxx2 = 1* radius + end * (sinPI3);                               
        dc.fillPolygon([[kxx, kyy], [xx, yy] ,[xx2,yy2],[kxx2, kyy2]]);
    }

    function drawsec(dc, rad2)
    {  
        var dateInfo = Time.Gregorian.info( Time.now(), Time.FORMAT_SHORT );
        var sec  = dateInfo.sec;            
        for (var k = 0; k <=59; k++)
        {
            if ( ( k >= ( sec - 4 ) ) && ( k<=sec)){    
                dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
                var xx, xx2, yy, yy2,kxx,kyy,kxx2,kyy2, winkel;
                winkel = 180 +k * -6;
                //      1 Polygon moving around a bigger and smaller circle
                //        xx/yy----------------xx2/yy2
                //          \                     /
                //           \                   /          --> 
                //            \                 / 
                //         kxx/kyy---------kxx2/kyy2   
                yy  = 1+radius * (1+Math.cos(Math.PI*(winkel-2)/180));
                yy2 = 1+radius * (1+Math.cos(Math.PI*(winkel+3)/180));  
                xx  = 1+ radius * (1+Math.sin(Math.PI*(winkel-2)/180));
                xx2 = 1+ radius * (1+Math.sin(Math.PI*(winkel+3)/180)); 
                kyy  = 1+radius + rad2 * (Math.cos(Math.PI*(winkel-2)/180)); 
                kyy2 = 1+radius + rad2 * (Math.cos(Math.PI*(winkel+3)/180));  
                kxx  = 1+ radius + rad2 * (Math.sin(Math.PI*(winkel-2)/180));
                kxx2 = 1+ radius + rad2 * (Math.sin(Math.PI*(winkel+3)/180));                               
                if ( k == sec ){dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_DK_RED); }  
                if ( k == sec - 1 ){dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_RED);}
                if ( k == sec - 2 ){dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY);}
                if ( k == sec - 3 ){dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_LT_GRAY);}
                if ( k == sec - 4 ){dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);}    
                if (yy > 180) {yy = yy -1; yy2 = yy2 -1;} 
                // finally draw the ploygon with 4 coordinates
                dc.fillPolygon([[kxx, kyy], [xx, yy] ,[xx2,yy2],[kxx2, kyy2]]);
            }  
        }
    }

   // Draw an arc with polygons 
   // https://forums.garmin.com/showthread.php?231881-Arc-Function&p=568317#post568317
    function drawPolygonArc(dc, x, y, radius, thickness, angle, offsetIn, color, direction){    	
        var curAngle;
        direction = direction*-1;
        var ptCnt = 30;
        
        if(angle > 0f){
          var pts = new [ptCnt*2+2];
          var offset = 90f*direction+offsetIn;
          var dec = angle / ptCnt.toFloat();
          for(var i=0,angle=0; i <= ptCnt; angle+=dec){
            curAngle = direction*(angle-offset)*deg2rad;
            pts[i] = [x+radius*Math.cos(curAngle), y+radius*Math.sin(curAngle)];
            i++;
          }
          for(var i=ptCnt+1; i <= ptCnt*2+1; angle-=dec){
            curAngle = direction*(angle-offset)*deg2rad;
            pts[i] = [x+(radius-thickness)*Math.cos(curAngle), y+(radius-thickness)*Math.sin(curAngle)];
            i++;
          }
          dc.setColor(color,Gfx.COLOR_TRANSPARENT);
          dc.fillPolygon(pts);
        }
    }

    function onExitSleep()
    {
        highPowerMode = true;
        Ui.requestUpdate();
    }

    function onEnterSleep() 
    {
        highPowerMode = false;
        Ui.requestUpdate();
    }

    // ============================================================
    // Function to rebuild the background which can be saved to png
    // ============================================================
    function drawFenix3Background(dc)
    {
        var width, height;
        width = dc.getWidth();
        height = dc.getHeight();
        radius = height/2;

        // ============================================================
        // Draw the battery arc
        var bar_width = 8;
        drawPolygonArc(dc, width/2, height/2, height/2, bar_width, 88,88, Gfx.COLOR_YELLOW, CLOCKWISE);
        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_YELLOW);
        drawWedge(dc,59.5,2,-10,8);
        drawWedge(dc,45.5,2,-10,8);

        // ============================================================
        // Draw the move arc
        drawPolygonArc(dc, width/2, height/2, height/2, bar_width, 88,179, Gfx.COLOR_YELLOW, CLOCKWISE);
        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_YELLOW);
        drawWedge(dc,45.5,2,-10,8);
        drawWedge(dc,30.5,2,-10,8);

        // ============================================================
        // Draw the activity arc
        drawPolygonArc(dc, width/2, height/2, height/2, bar_width ,  88, 179, Gfx.COLOR_YELLOW, COUNTERCLOCKWISE);
        drawPolygonArc(dc, width/2, height/2, height/2, bar_width/3, 88,179, Gfx.COLOR_BLUE, COUNTERCLOCKWISE);
        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLUE);
        drawWedge(dc,15.5,2,-10,8);
        drawWedge(dc,29.5,2,-10,8);

        // ============================================================
        // Draw the Move icon
        var dimensions =  dc.getTextDimensions("Move",Gfx.FONT_XTINY);
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(width/5, height*.72,
                                dimensions[0]+5, dimensions[1]-2, 4);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        
        dc.drawText(width/5+2, height*.71,
                    Gfx.FONT_XTINY, "Move", Gfx.TEXT_JUSTIFY_LEFT);

        // ============================================================
        // Draw the Battery icon
//        dimensions =  dc.getTextDimensions(" 100%",Gfx.FONT_XTINY);
//        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
//        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
//        dc.fillRoundedRectangle(width/5, height*.21,
//                                dimensions[0]+5, dimensions[1]-2, 4);
//        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
//        dc.drawText(width/5+2, height*.20,
//                    Gfx.FONT_XTINY, " 100%", Gfx.TEXT_JUSTIFY_LEFT);

        // ============================================================
        // Draw the logo
//        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
//        dc.drawText(width* 0.77  , height*.19,
//                    Gfx.FONT_XTINY, deviceName, Gfx.TEXT_JUSTIFY_RIGHT);
//                    //Gfx.FONT_XTINY, "fēnix 3", Gfx.TEXT_JUSTIFY_RIGHT);
//        dc.drawText(width* 0.77  , height*.19 + 14,
//                    Gfx.FONT_XTINY, "10 ATM", Gfx.TEXT_JUSTIFY_RIGHT);
        // Draw the minute marks
        drawMinuteMarks(dc);

        // Draw the steps icon
//        dc.drawBitmap(width* 0.70+4, height*.65,steps);
    }

    // ============================================================
    // Draw segment from center 
    // ============================================================
    function drawSegment(dc, startmin, endmin, colour)
    {
        var startangle = (180- startmin * 6 ) * deg2rad;
        var endangle = (180- endmin * 6 )  * deg2rad;
        var xcenter = radius;
        var ycenter = radius;
        var startx = xcenter + (50+ radius) * Math.sin(startangle);
        var starty = ycenter + (50+ radius) * Math.cos(startangle);
        var   endx = xcenter + (50+ radius) * Math.sin(  endangle);
        var   endy = ycenter + (50+ radius) * Math.cos(  endangle);
        // Map out the coordinates 
        var coords = [ [radius,radius], [startx, starty], [endx,endy] ];

        // Draw the polygon
        dc.setColor(colour,colour);
        dc.fillPolygon(coords);
    }

    // ============================================================
    //! Handle the update event
    function onUpdate(dc)
    {
        var width, height;
        width = dc.getWidth();
        height = dc.getHeight();
        radius = height/2;
        var clockTime = Sys.getClockTime();
        var hour;
        var min;
        var activityInfo;
        var bar_width = 8;
//drawBackground(dc);
//return;
        activityInfo = Act.getInfo();
        //prevent divide by 0 if stepGoal is 0
        if( activityInfo != null && activityInfo.stepGoal == 0 )
        {
            activityInfo.stepGoal = 5000;
        }

        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);

        var dateStr = Lang.format("$1$ $2$", [info.month, info.day]);
        hour = ( ( ( clockTime.hour % 12 ) * 60 ) + clockTime.min );

        // ============================================================
        // Adjust the date position 
        if  ((hour >  160  && hour < 200) ||
             (clockTime.min > 13 && clockTime.min < 17))
        {
            switch_date = true;
        }
        else
        {
            switch_date = false;
        }

        // ============================================================
        // Clear the screen
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.fillRectangle(0,0,width, height);

        // ============================================================
        // Draw the move bar
        if (debug && activityInfo != null) 
        {
            activityInfo.moveBarLevel = moveBarLevel; 
            moveBarLevel++; 
        }
        var bar_length = 9;
        if (activityInfo) 
        {
            if (activityInfo.moveBarLevel > 0 )
            {
                drawSegment(dc,   30,35  , Gfx.COLOR_RED );
                if (activityInfo.moveBarLevel >1 )
                {
                      drawSegment(dc,   35.5,37.5, Gfx.COLOR_RED );
                    if (activityInfo.moveBarLevel >2 )
                    {
                          drawSegment(dc,   38,40  , Gfx.COLOR_RED );
                        if (activityInfo.moveBarLevel >3 )
                        {
                              drawSegment(dc,   40.5,42.5  , Gfx.COLOR_RED );
                            if (activityInfo.moveBarLevel >4 )
                            {
                                  drawSegment(dc,   43,45  , Gfx.COLOR_RED );
                            }
                        }
                    }
                }
            }

            // ============================================================
            // Draw the activity arc
            var progress = 1f*activityInfo.steps/activityInfo.stepGoal;
            if (progress > 1) {progress = 1;}
            drawSegment(dc,   30, 30-15*progress  , Gfx.COLOR_BLUE );
        }

        // ============================================================
        // Draw the battery arc
        var battery = Sys.getSystemStats().battery/100;
        var NUM_SEGMENTS = 6;
        //var segment_colour = [ Gfx.COLOR_DK_RED, Gfx.COLOR_ORANGE, Gfx.COLOR_YELLOW, Gfx.COLOR_DK_GREEN, Gfx.COLOR_GREEN];
        var segment_colour = [ Gfx.COLOR_DK_RED, Gfx.COLOR_ORANGE, Gfx.COLOR_DK_GREEN, Gfx.COLOR_DK_GREEN, Gfx.COLOR_GREEN, Gfx.COLOR_GREEN];
        var BOUNDARY = 1f/NUM_SEGMENTS;
        var SEGMENT_SIZE = 15f/NUM_SEGMENTS;
        var GAUGE_START = 45;
        for (var count = 1; count <= NUM_SEGMENTS ; count++)
        {
            if (battery > (BOUNDARY*count)) // Draw full segment 
            { 
                drawSegment(dc,   GAUGE_START + (count-1)*SEGMENT_SIZE, 
                                  GAUGE_START+(count)*SEGMENT_SIZE, 
                                  segment_colour[count-1] ); 
            }
            else// Draw partial segment
            { 
              var partial = GAUGE_START + (count-1)*SEGMENT_SIZE + ((battery-(count-1)*BOUNDARY) / BOUNDARY) * SEGMENT_SIZE; 
              var remain =  ((battery-(count-1)*BOUNDARY));
                drawSegment(dc, GAUGE_START + (count-1)*SEGMENT_SIZE, 
                                partial,
                                segment_colour[count-1] ); 
                break;
            }
        }

        // ============================================================
        // Draw the background
        dc.drawBitmap(0,0,background);

        // ============================================================
        // Draw the Sleep icon
        if (activityInfo != null && activityInfo.isSleepMode  )
        {
            var dimensions =  dc.getTextDimensions(" zzZZ ",Gfx.FONT_XTINY);
            dc.setColor(Gfx.COLOR_DK_BLUE,Gfx.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(width/5, height*.72,
                                    dimensions[0]+5, dimensions[1]-2, 4);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(width/5+2, height*.71,
                        Gfx.FONT_XTINY, "zzZZ", Gfx.TEXT_JUSTIFY_LEFT);
        }
        // Or the Move icon
        else if (activityInfo != null && activityInfo.moveBarLevel > 0 )
        {
            var dimensions =  dc.getTextDimensions("Move!",Gfx.FONT_XTINY);
            //dc.setColor(Gfx.COLOR_RED,Gfx.COLOR_RED);
            dc.setColor(Gfx.COLOR_DK_RED,Gfx.COLOR_DK_RED);
            dc.fillRoundedRectangle(width/5, height*.72,
                                    dimensions[0]+5, dimensions[1]-2, 4);
            //dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(width/5+2, height*.71,
                        Gfx.FONT_XTINY, "Move!", Gfx.TEXT_JUSTIFY_LEFT);
        }

        // ============================================================
        // Draw the numbers
        drawTwelve(dc);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(width/2,height-45,font,"6", Gfx.TEXT_JUSTIFY_CENTER);
        var dimensions =  dc.getTextDimensions(dateStr,Gfx.FONT_SMALL);

        // ============================================================
        // Draw the name
        dc.drawText(width* 0.77  , height*.19,
                    Gfx.FONT_XTINY, deviceName, Gfx.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width* 0.77  , height*.19 + 14,
                    Gfx.FONT_XTINY, "10 ATM", Gfx.TEXT_JUSTIFY_RIGHT);
        // ============================================================
        // Draw the date
        var date_pos = 0;
        if (switch_date) 
        {
            date_pos = 20;
            dc.drawText(width-22,-15+height/2,font, "3", Gfx.TEXT_JUSTIFY_RIGHT);
        }
        else
        {
            date_pos = width-22-dimensions[0];
            dc.drawText(16,-15+height/2,font,"9",Gfx.TEXT_JUSTIFY_LEFT);
        }
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT); // drop shadow
        dc.fillRoundedRectangle(date_pos-3, -dimensions[1]/2+height/2-2,
                                dimensions[0]+5, dimensions[1]-2, 8);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(date_pos, -dimensions[1]/2+height/2,
                                dimensions[0]+5, dimensions[1]-2, 8);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.drawText(date_pos+1, -dimensions[1]/2 -1 + height/2, 
                    Gfx.FONT_SMALL, dateStr, Gfx.TEXT_JUSTIFY_LEFT);

        // ============================================================
        // Draw the hour hand. Convert it to minutes and
        // compute the angle.
        hour = hour / (12 * 60.0);
        drawHourHand(dc, hour * Math.PI * 2);

        // ============================================================
        // Draw the minute hand
        min = ( clockTime.min / 60.0) * Math.PI * 2;
        drawMinuteHand(dc, min);

        // ============================================================
        // Draw the second hand
        if (highPowerMode == true)
        {
          var sec  = ( clockTime.sec / 60.0) * Math.PI * 2;
          drawSecondHand(dc, sec);
        }

        // ============================================================
        // Draw the inner circle
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
        dc.fillCircle(width/2, height/2, 7);
        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
        dc.drawCircle(width/2, height/2, 7 );
    }
}


class Testbed extends App.AppBase
{
    function onStart()
    {
    }

    function onStop()
    {
    }

    function getInitialView()
    {
        return [new TestbedFace()];
    }
}
