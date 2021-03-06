(**************************************************************************)
(*                Lablgtk                                                 *)
(*                                                                        *)
(*    This program is free software; you can redistribute it              *)
(*    and/or modify it under the terms of the GNU Library General         *)
(*    Public License as published by the Free Software Foundation         *)
(*    version 2, with the exception described in file COPYING which       *)
(*    comes with the library.                                             *)
(*                                                                        *)
(*    This program is distributed in the hope that it will be useful,     *)
(*    but WITHOUT ANY WARRANTY; without even the implied warranty of      *)
(*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       *)
(*    GNU Library General Public License for more details.                *)
(*                                                                        *)
(*    You should have received a copy of the GNU Library General          *)
(*    Public License along with this program; if not, write to the        *)
(*    Free Software Foundation, Inc., 59 Temple Place, Suite 330,         *)
(*    Boston, MA 02111-1307  USA                                          *)
(*                                                                        *)
(*                                                                        *)
(**************************************************************************)

(* $Id: gMisc.mli 1527 2010-09-09 08:02:22Z garrigue $ *)

open Gtk
open GObj
open GContainer

(** Miscellaneous widgets *)

(** @gtkdoc gtk GtkSeparator
    @gtkdoc gtk GtkHSeparator
    @gtkdoc gtk GtkVSeparator *)
val separator :
  Tags.orientation ->
  ?packing:(widget -> unit) -> ?show:bool -> unit -> widget_full

(** {3 Statusbar} *)

class statusbar_context :
  Gtk.statusbar obj -> Gtk.statusbar_context ->
  object
    val context : Gtk.statusbar_context
    val obj : Gtk.statusbar obj
    method context : Gtk.statusbar_context
    method flash : ?delay:int -> string -> unit
    (** @param delay default value is [1000] ms *)
    method pop : unit -> unit
    method push : string -> statusbar_message
    method remove : statusbar_message -> unit
  end

(** Report messages of minor importance to the user
    @gtkdoc gtk GtkStatusbar *)
class statusbar : Gtk.statusbar obj ->
  object
    inherit GPack.box
    val obj : Gtk.statusbar obj
    method new_context : name:string -> statusbar_context
    method has_resize_grip : bool
    method set_has_resize_grip : bool -> unit
  end

(** @gtkdoc gtk GtkStatusbar *)
val statusbar :
  ?has_resize_grip:bool ->
  ?border_width:int ->
  ?width:int ->
  ?height:int ->
  ?packing:(widget -> unit) -> ?show:bool -> unit -> statusbar

(** {3 Misc. Widgets} *)

(** A base class for widgets with alignments and padding
    @gtkdoc gtk GtkMisc *)
class misc : ([> Gtk.misc] as 'a) obj ->
  object
    inherit GObj.widget
    val obj : 'a obj
    method set_xalign : float -> unit
    method set_yalign : float -> unit
    method set_xpad : int -> unit
    method set_ypad : int -> unit
    method xalign : float
    method yalign : float
    method xpad : int
    method ypad : int
  end

type image_type =
  [ `EMPTY | `PIXMAP | `IMAGE | `PIXBUF | `STOCK | `ICON_SET | `ANIMATION ]

(** A widget displaying an image
    @gtkdoc gtk GtkImage *)
class image : 'a obj ->
  object
    inherit misc
    constraint 'a = [> Gtk.image]
    val obj : 'a obj
    method clear : unit -> unit (** since Gtk 2.8 *)
    method storage_type : image_type
    method set_image : Gdk.image -> unit
    method set_mask : Gdk.bitmap option -> unit
    method set_file : string -> unit
    method set_pixbuf : GdkPixbuf.pixbuf -> unit
    method set_stock : GtkStock.id -> unit
    method set_icon_set : icon_set -> unit
    method set_icon_size : Tags.icon_size -> unit
    method set_pixel_size : int -> unit
    method image : Gdk.image
    method mask : Gdk.bitmap option
    method pixbuf : GdkPixbuf.pixbuf
    method pixel_size : int
    method stock : GtkStock.id
    method icon_set : icon_set
    method icon_size : Tags.icon_size
  end

(** @gtkdoc gtk GtkImage *)
val image :
  ?file:string ->
  ?image:Gdk.image ->
  ?pixbuf:GdkPixbuf.pixbuf ->
  ?pixel_size:int ->
  ?pixmap:Gdk.pixmap ->
  ?mask:Gdk.bitmap ->
  ?stock:GtkStock.id ->
  ?icon_set:icon_set ->
  ?icon_size:Tags.icon_size ->
  ?xalign:float ->
  ?yalign:float ->
  ?xpad:int ->
  ?ypad:int ->
  ?width:int ->
  ?height:int ->
  ?packing:(widget -> unit) -> ?show:bool -> unit -> image


(** {4 Labels} *)

(** @gtkdoc gtk GtkLabel *)
class label_skel : 'a obj ->
  object
    inherit misc
    constraint 'a = [> Gtk.label]
    val obj : 'a obj
    method cursor_position : int
    method selection_bound : int
    method selection_bounds : (int * int) option
    method select_region : int -> int -> unit
    method set_justify : Tags.justification -> unit
    method set_label : string -> unit
    method set_line_wrap : bool -> unit
    method set_mnemonic_widget : widget option -> unit
    method set_pattern : string -> unit
    method set_selectable : bool -> unit
    method set_text : string -> unit
    method set_use_markup : bool -> unit
    method set_use_underline : bool -> unit
    method justify : Tags.justification
    method label : string
    method line_wrap : bool
    method mnemonic_keyval : int
    method mnemonic_widget : widget option
    method selectable : bool
    method text : string
    method use_markup : bool
    method use_underline : bool

    method angle : float (** @since GTK 2.6 *)
    method set_angle : float -> unit (** @since GTK 2.6 *)
    method max_width_chars : int (** @since GTK 2.6 *)
    method set_max_width_chars : int -> unit (** @since GTK 2.6 *)
    method single_line_mode : bool (** @since GTK 2.6 *)
    method set_single_line_mode : bool -> unit (** @since GTK 2.6 *)
    method width_chars : int (** @since GTK 2.6 *)
    method set_width_chars : int -> unit (** @since GTK 2.6 *)
    method ellipsize : PangoEnums.ellipsize_mode (** @since GTK 2.6 *)
    method set_ellipsize : PangoEnums.ellipsize_mode -> unit (** @since GTK 2.6 *)
  end

(** A widget that displays a small to medium amount of text
   @gtkdoc gtk GtkLabel *)
class label : Gtk.label obj ->
  object
    inherit label_skel
    val obj : Gtk.label obj
    method connect : widget_signals
  end

(** @gtkdoc gtk GtkLabel
    @param markup overrides [text] if both are present
    @param use_underline default value is [false]
    @param justify default value is [`LEFT]
    @param selectable default value is [false]
    @param line_wrap default values is [false] *)
val label :
  ?text:string ->
  ?markup:string ->     (* overrides ~text if present *)
  ?use_underline:bool ->
  ?mnemonic_widget:#widget ->
  ?justify:Tags.justification ->
  ?line_wrap:bool ->
  ?pattern:string ->
  ?selectable:bool ->
  ?ellipsize:PangoEnums.ellipsize_mode ->
  ?xalign:float ->
  ?yalign:float ->
  ?xpad:int ->
  ?ypad:int ->
  ?width:int ->
  ?height:int ->
  ?packing:(widget -> unit) -> ?show:bool -> unit -> label
val label_cast : < as_widget : 'a obj ; .. > -> label

(** {4 Tips query} *)

(** @gtkdoc gtk GtkTipsQuery
    @deprecated . *)
class tips_query_signals : Gtk.tips_query obj ->
  object
    inherit GObj.widget_signals
    method start_query : callback:(unit -> unit) -> GtkSignal.id
    method stop_query : callback:(unit -> unit) -> GtkSignal.id
    method widget_entered :
      callback:(widget option -> text:string -> privat:string -> unit) ->
      GtkSignal.id
    method widget_selected :
      callback:(widget option -> text:string -> privat:string ->
                GdkEvent.Button.t -> bool) ->
      GtkSignal.id
  end

(** Displays help about widgets in the user interface
    @gtkdoc gtk GtkTipsQuery
    @deprecated . *)
class tips_query : Gtk.tips_query obj ->
  object
    inherit label_skel
    val obj : Gtk.tips_query obj
    method connect : tips_query_signals
    method start : unit -> unit
    method stop : unit -> unit
    method set_caller : widget option -> unit
    method set_emit_always : bool -> unit
    method set_label_inactive : string -> unit
    method set_label_no_tip : string -> unit
    method caller : widget option
    method emit_always : bool
    method label_inactive : string
    method label_no_tip : string
  end

(** @gtkdoc gtk GtkTipsQuery
    @deprecated . *)
val tips_query :
  ?caller:#widget ->
  ?emit_always:bool ->
  ?label_inactive:string ->
  ?label_no_tip:string ->
  ?xalign:float ->
  ?yalign:float ->
  ?xpad:int ->
  ?ypad:int ->
  ?width:int ->
  ?height:int ->
  ?packing:(widget -> unit) -> ?show:bool -> unit -> tips_query
