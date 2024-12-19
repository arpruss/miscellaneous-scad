/*
Copyright (c) 2016 Lars Christensen
Modifications (c) 2024 Alexander Pruss

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

w_divider_color = "CadetBlue";
h_divider_color = "CornflowerBlue";
front_color = "RoyalBlue";
back_color = "RoyalBlue";
bottom_color = "SlateBlue";
top_color = "SlateBlue";
left_color = "MediumAquamarine";
right_color = "MediumAquamarine";
e = 0.01;

BOX_CHILD_BOTTOM = 0;
BOX_CHILD_TOP = 1;
BOX_CHILD_FRONT = 2;
BOX_CHILD_BACK = 3;
BOX_CHILD_LEFT = 4;
BOX_CHILD_RIGHT = 5;

module box(width, height, depth, thickness,
           finger_width, // (default = 2 * thickness)
           finger_margin, // (default = 2 * thickness)
           inner = false,
           open = false,
           open_bottom = false,
           inset = 0,
           dividers = [ 0, 0 ],
           holes = [],
           hole_dia = 0,
           ears = 0,
           assemble = false,
           hole_width = false,
           kerf = 0.0,
           labels = false,
           explode = 0,
           spacing = 0)
{
  vlayers = (open ? 0 : 1) + (open_bottom ? 0 : 1);
  w = inner ? width + 2 * thickness : width;
  h = inner ? height + vlayers * thickness : height;
  d = inner ? depth + 2 * thickness : depth;
  t = thickness;
  hm = h - inset;
  fm = (finger_margin == undef) ? thickness * 2 : finger_margin;
  fw = (finger_width == undef) ? thickness * 2 : finger_width;
  keep_top = !open;
  keep_bottom = !open_bottom;
  kc = kerf / 2;
  ears_radius = ears;
  ears_width = 3;

  // Kerf compensation modifier
  module compkerf() { offset(delta = kc) children(); }

  // 2D panels with finger cuts
  module left() { 
      difference() {
        { cut_left() panel2d(d, h); }
        children();
      }
  }
  module right() { 
      difference() {
        { cut_right() panel2d(d, h); }
        children();
      }
  }
  module top() { 
    difference() {
      union() {
        if (ears_radius > 0) {
          assert(ears_radius >= sqrt(2)*thickness+ears_width, "ears are too small");
          difference() {
            panel2d(w, d);
            translate([t, d-t+e]) panel2d(2*t, t);
            translate([t, -e]) panel2d(2*t, t);
          }
        } else {
          cut_top() panel2d(w, d);
        }
    }
    children();
    }
  }
  
  module bottom() { 
      difference() {
        { cut_bottom() panel2d(w, d); }
        children();
      }
  }
  
  module ears_outer(is_front) {
    translate([is_front ? 0 : w, h]) 
      circle(r=ears_radius);
  }
  module ears_inner(is_front) {
    translate([is_front ? 0 : w, h])
      difference() {
      circle(r=ears_radius-ears_width);
      square([t, t]);
    }
  }
  
  module back() {
    difference() {
        cut_back() difference() {
          union() {
            panel2d(w, h);
            if (ears_radius > 0)
              ears_outer(false);
          }
          if (len(holes) > 0)
            for (i = [ 0 : len(holes)-1 ])
              hole([w-holes[i][0], holes[i][1]]);
          if (ears_radius > 0)
            ears_inner(false);
        }
        children();
    }
  }
  
  module hole(center) {
    translate(center) circle(d = hole_dia);
  }
  
  module front() {
    difference() {
        cut_front() difference() {
          union()
          {
            panel2d(w, h); 
            if (ears_radius > 0)
              ears_outer(true);
          }
          if (len(holes) > 0)
            for (i = [ 0 : len(holes)-1 ])
              hole(holes[i]);
          if (ears_radius > 0)
            ears_inner(true);
        }
        children();
    }
  }

  module w_divider() { cut_w_divider() translate([0, t, 0]) panel2d(w, h-t); }
  module h_divider() { cut_h_divider() translate([0, t, 0]) panel2d(d, h-t); }

  // Panels positioned in 3D
  module front3d() {
    translate([0,t-explode,0])
      rotate(90, [1,0,0])
      panelize(w,h, "Front", front_color)
      front() children();
  }

  module back3d() {
    translate([w,d-t+explode,0])
      rotate(-90, [1,0,0])
      rotate(180,[0,0,1])
      panelize(w, h, "Back", back_color)
      back() children();
  }

  module bottom3d() {
    translate([w,0,t-explode])
      rotate(180,[0,1,0])
      panelize(w, d, "Bottom", bottom_color)
      bottom() children();
  }

  module top3d() {
    translate([0, 0, h-t+explode+(ears_radius > 0 ? t : 0)])
      panelize(w, d, "Top", top_color)
      top() children();
  }

  module left3d() {
    translate([t-explode,d,0])
      rotate(-90,[0,1,0])
      rotate(-90,[0,0,1])
      panelize(d, h, "Left", left_color)
      left() children();
  }

  module right3d() {
    translate([w-t+explode,0,0])
      rotate(90,[0,1,0])
      rotate(90,[0,0,1])
      panelize(d, h, "Right", right_color)
      right() children();
  }

  module w_divider3d() {
    if (dividers[0] > 0) {
      ndivs = dividers[0];
      for (i = [ 1 : 1 : ndivs ])
        translate([0, d/(ndivs+1)*i+t/2,0])
          rotate(90, [1,0,0])
          panelize(w,h, "Divider", w_divider_color)
          w_divider();
    }
  }

  module h_divider3d() {
    translate([0,0,explode > e && dividers[0] > 0 ? h + explode : explode])
      if (dividers[1] > 0) {
        ndivs = dividers[1];
        for (i = [1 : 1 : ndivs])
          translate([w/(ndivs+1)*i-t/2,0,0])
            rotate(90, [1,0,0])
            rotate(90, [0,1,0])
            panelize(d,h, "Divider", h_divider_color)
            h_divider();
      }
  }

  module w_dividers() {
    if (dividers[0] > 0) {
      ndivs = dividers[0];
      for (i = [0 : 1 : ndivs-1])
        translate([i*(w+e)+spacing*(i+1),0,0])
          w_divider();
    }
  }

  module h_dividers() {
    if (dividers[1] > 0) {
      ndivs = dividers[1];
      for (i = [0 : 1 : ndivs-1])
        translate([i*(d+e)+spacing*(i+1),0,0])
          h_divider();
    }
  }

  // Panelized 2D rendering for cutting
  module box2d() {
    compkerf() front() if ($children > BOX_CHILD_FRONT) children(BOX_CHILD_FRONT);
    x1 = w + kc * 2 + e + spacing;
    translate([x1,0]) compkerf() back() if ($children > BOX_CHILD_BACK) children(BOX_CHILD_BACK);
    x2 = x1 + w + 2 * kc + e + ears_radius + spacing;
    translate([x2,0]) compkerf() left() if ($children > BOX_CHILD_LEFT) children(BOX_CHILD_LEFT);
    x3 = x2 + d + 2 * kc + e + spacing;
    translate([x3,0]) compkerf() right() if ($children > BOX_CHILD_RIGHT) children(BOX_CHILD_RIGHT);
    y1 = h + kc * 2 + e + ears_radius + spacing;
    if (keep_bottom) {
      x4 = 0;
      translate([x4,y1]) compkerf() bottom() if ($children > BOX_CHILD_BOTTOM) children(BOX_CHILD_BOTTOM);
    }
    if (keep_top) {
      x5 = w + 2 * kc + e + spacing;
      translate([x5,y1]) compkerf() top() if($children>BOX_CHILD_TOP) children(BOX_CHILD_TOP);
    }
    x6 = w + 2 * kc + (keep_top ? w+e : 0) + e + spacing;
    translate([x6,y1]) compkerf() w_dividers();
    translate([x6+kerf,y1 + (dividers[0] > 0 ? y1 : 0)]) compkerf() h_dividers();
  }

  // Assembled box in 3D
  module box3d() {
    front3d() if ($children > BOX_CHILD_FRONT) children(BOX_CHILD_FRONT);
    back3d() if ($children > BOX_CHILD_BACK) children(BOX_CHILD_BACK);
    if (keep_bottom)
      translate([0,0,inset]) bottom3d() if ($children > BOX_CHILD_BOTTOM) children(BOX_CHILD_BOTTOM);
    if (keep_top)
      top3d() if ($children > BOX_CHILD_TOP) children(BOX_CHILD_TOP);
    left3d() if ($children > BOX_CHILD_LEFT) children(BOX_CHILD_LEFT);
    right3d() if ($children > BOX_CHILD_RIGHT) children(BOX_CHILD_RIGHT);
    w_divider3d();
    h_divider3d();
  }

  // Finger cutting operators
  module cut_front() {
    difference() {
      children();
      if (keep_bottom) translate([0,inset]) cuts(w);
      if (keep_top && (ears_radius == 0)) movecutstop(w, h) cuts(w);
      movecutsleft(w, h) cuts(h);
      movecutsright(w, h) cuts(h);
      if (dividers[1] > 0) {
        ndivs = dividers[1];
        for (i = [1 : 1 : ndivs])
          movecuts(w/(ndivs+1)*i-t/2, 0) cuts(h, li = thickness*2);
      }
      holecuts();
    }
  }

  module cut_w_divider() {
    difference() {
      children();
      movecutsleft(w, h) invcuts(h, ri = thickness*2);
      movecutsright(w, h) invcuts(h, li = thickness*2);
      if (dividers[1] > 0) {
        ndivs = dividers[1];
        for (i = [1 : 1 : ndivs])
          movecuts(w/(ndivs+1)*i-t/2, h/2) square([h / 2, thickness]);
      }
      holecuts();
    }
  }

  module cut_h_divider() {
    difference() {
      children();
      movecutsleft(d, h) invcuts(h, ri = thickness*2);
      movecutsright(d, h) invcuts(h, li = thickness*2);
      if (dividers[0] > 0) {
        ndivs = dividers[0];
        for (i = [1 : 1 : ndivs])
          movecuts(d/(ndivs+1)*i-t/2, 0) square([h / 2, thickness]);
      }
      holecuts();
    }
  }

  module cut_top() {
    difference() {
      children();
      invcuts(w);
      movecutstop(w, d) invcuts(w);
      movecutsleft(w, d) translate([t,0]) invcuts(d-2*t);
      movecutsright(w, d) translate([t,0]) invcuts(d-2*t);
    }
  }

  module cut_left() {
    difference() {
      children();
      if (keep_bottom) translate([t,inset]) cuts(d-2*t);
      if (keep_top && (ears_radius == 0)) movecutstop(d, h) translate([t,0]) cuts(d-2*t);
      movecutsleft(d, h) invcuts(h);
      movecutsright(d, h) invcuts(h);
      if (dividers[0] > 0) {
        ndivs = dividers[0];
        for (i = [1 : 1 : ndivs])
          movecuts(d/(ndivs+1)*i-t/2, 0) cuts(h, li = thickness*2);
      }
    }
  }

  module cut_bottom() { cut_top() children(); }
  module cut_right() { cut_left() children(); }
  module cut_back() { cut_front() children(); }

  // Handle hole
  module holecuts() {
    if (hole_width) {
      r = hole_height / 2;
      hull() {
        translate([w/2 - hole_width/2 + r, h - hole_margin - r])
          circle(r = r);
        translate([w/2 + hole_width/2 - r, h - hole_margin - r])
          circle(r = r);
      }
    }
  }

  // Finger cuts (along x axis)
  module cuts(tw, li = 0, ri = 0, full = false) {
    w = tw - li - ri;
    innerw = w - t*2 - 2 * fm;
    tc1 = floor((innerw / fw - 1) / 2);
    tc = (tc1 < 0) ? 0 : tc1;
    steps = tc * 2 + 1;

    fw_fitting = innerw / steps;

    // Use a default finger if we cant fit one within margins
    fw1 = (innerw < fw) ? fw : fw_fitting;
    // Divide length by 3 if we can fit less that 3 fingers
    fw2 = (tw < fw * 3) ? (tw / 3) : fw1;

    stepsize = fw2;

    x = (w - steps * stepsize) / 2;
    fw_minimum = t;

    if (tw >= 3 * fw_minimum) {
      translate([li,0])
        for (i = [0:tc]) {
          translate([x+i*stepsize*2,-e])
            square([stepsize, t+e]);
        }
    }
  }

  // Inverse finger cuts (along x axis)
  module invcuts(w, li = 0, ri = 0, full = true) {
    difference() {
      translate([-2*e,-e]) square([w+4*e,t+e]);
      cuts(w, li, ri, full);
    }
  }

  // Finger cut positioning operators
  module movecutstop(w, h) {
    translate([w,h,0])
      rotate(180,[0,0,1])
      children();
  }

  module movecutsleft(w, h) {
    translate([0, h/2])
      rotate(-90, [0,0,1])
      translate([-h/2,0])
      children();
  }

  module movecutsright(w, h) {
    translate([w-t,0])
      rotate(90,[0,0,1])
      translate([0,-t])
      children();
  }

  module movecuts(w, h) {
    translate([w, h])
      rotate(90,[0,0,1])
      translate([0,-t])
      children();
  }

  // Turn 2D Panel into 3D
  module panelize(x, y, name, cl) {
    color(cl)
      linear_extrude(height = t)
      children();
    if (labels) {
      color("Yellow")
        translate([x/2,y/2,t+1])
        text(text = name, halign = "center", valign="center");
    }
  }

  module panel2d(x, y) {
    square([x,y]);
  }

  if (assemble)
    box3d() {
        if ($children>0)
            children(0);
        if ($children>1)
            children(1);
        if ($children>2)
            children(2);
        if ($children>3)
            children(3);
        if ($children>4)
            children(4);
        if ($children>5)
            children(5);
    }
  else
    box2d() {
        if ($children>0)
            children(0);
        if ($children>1)
            children(1);
        if ($children>2)
            children(2);
        if ($children>3)
            children(3);
        if ($children>4)
            children(4);
        if ($children>5)
            children(5);
  }
}