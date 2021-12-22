M = {
    out_of_bounds_x = function(x, max_width) return (x < 0 or x >= max_width) end,

    out_of_bounds_y = function(y, max_height)
        return (y < 0 or y >= max_height)
    end,

    collided = function(left, right)
        return
            left.x < right.x + right.width and right.x < left.x + left.width and
                left.y < right.y + right.height and right.y < left.y +
                left.height
    end
}

return M
