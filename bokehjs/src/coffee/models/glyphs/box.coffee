import {RBush} from "core/util/spatial"
import {Glyph, GlyphView} from "./glyph"
import * as hittest from "core/hittest"
import * as p from "core/properties"

# Not a publicly exposed Glyph, exists to factor code for bars and quads

export class BoxView extends GlyphView

  _index_box: (len) ->
    points = []

    for i in [0...len]
      [l, r, t, b] = @_lrtb(i)
      if isNaN(l+r+t+b) or not isFinite(l+r+t+b)
        continue
      points.push({minX: l, minY: b, maxX: r, maxY: t, i: i})

    return new RBush(points)

  _render: (ctx, indices, {sleft, sright, stop, sbottom}) ->
    for i in indices
      if isNaN(sleft[i]+stop[i]+sright[i]+sbottom[i])
        continue

      if @visuals.fill.doit
        @visuals.fill.set_vectorize(ctx, i)
        ctx.fillRect(sleft[i], stop[i], sright[i]-sleft[i], sbottom[i]-stop[i])

      if @visuals.line.doit
        ctx.beginPath()
        ctx.rect(sleft[i], stop[i], sright[i]-sleft[i], sbottom[i]-stop[i])
        @visuals.line.set_vectorize(ctx, i)
        ctx.stroke()

  _hit_point: (geometry) ->
    [vx, vy] = [geometry.vx, geometry.vy]
    x = @renderer.xscale.invert(vx)
    y = @renderer.yscale.invert(vy)

    hits = @index.indices({minX: x, minY: y, maxX: x, maxY: y})

    result = hittest.create_hit_test_result()
    result['1d'].indices = hits
    return result

  _hit_span: (geometry) ->

    [vx, vy] = [geometry.vx, geometry.vy]

    if geometry.direction == 'v'
      y = @renderer.yscale.invert(vy)
      hr = @renderer.plot_view.frame.h_range
      minX = @renderer.xscale.invert(hr.min)
      maxX = @renderer.xscale.invert(hr.max)
      hits = @index.indices({ minX: minX, minY: y, maxX: maxX, maxY: y })
    else
      x = @renderer.xscale.invert(vx)
      vr = @renderer.plot_view.frame.v_range
      minY = @renderer.yscale.invert(vr.min)
      maxY = @renderer.yscale.invert(vr.max)
      hits = @index.indices({ minX: x, minY: minY, maxX: x, maxY: maxY })

    result = hittest.create_hit_test_result()
    result['1d'].indices = hits
    return result

  draw_legend_for_index: (ctx, x0, x1, y0, y1, index) ->
    @_generic_area_legend(ctx, x0, x1, y0, y1, index)

export class Box extends Glyph
  @mixins ['line', 'fill']
