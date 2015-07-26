/+
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org>
+/
module tagged_union;
import std.typetuple;

struct TaggedUnion(Types_...)
{
    alias Types = Types_;
    private size_t index = size_t.max;
    union
    {
        private Types data;
    }

    this(T)(T type) if (IndexOf!T != -1)
    {
        this = type;
    }

    auto ref opAssign(T)(T type) if (IndexOf!T != -1)
    {
        set!T(type);
    }

@property:

    auto id() const
    {
        return index;
    }

    pure @trusted auto ref getID(size_t id)() inout if (id < Types.length)
    {
        assert(index == id);
        return data[id];
    }

    pure @trusted auto ref setID(size_t id)(Types[id] type) if (id < Types.length)
    {
        index = id;
        data[id] = type;
    }

    auto ref get(Type)() if (IndexOf!Type != -1)
    {
        return getID!(IndexOf!Type);
    }

    auto ref set(Type)(Type type) if (IndexOf!Type != -1)
    {
        return setID!(IndexOf!Type)(type);
    }

    auto toString()
    {
        foreach (c, Type; Types)
        {
            if (id == c)
            {
                import std.conv;

                return (getID!c).to!string;
            }
        }
        return "";
    }

    template IndexOf(Type)
    {
        enum IndexOf = staticIndexOf!(Type, Types);
    }
}

pure @safe unittest
{
    alias Union = TaggedUnion!(int, string);
    Union a = 5;
    Union b = "c";
    b = a;
    assert(a.id == 0);
    assert(a.getID!0 == 5);
    assert(a.get!int == 5);
    import std.conv;

    assert((a.getID!0).to!string == (5.to!string));
    static assert(!is(typeof(a.getID!0) == const));
    
    const Union c = 7;
    static assert(is(typeof(c.getID!0) == const));
}
