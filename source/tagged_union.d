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

    this(T)(T type) if (staticIndexOf!(T, Types) != -1)
    {
        this = type;
    }

    auto ref opAssign(T)(T type) if (staticIndexOf!(T, Types) != -1)
    {
        set!T(type);
    }

@property:

    auto id()
    {
        return index;
    }

    pure @trusted auto ref getID(size_t id)() if (id < Types.length)
    {
        assert(index == id);
        return data[id];
    }

    pure @trusted auto ref setID(size_t id)(Types[id] type) if (id < Types.length)
    {
        index = id;
        data[id] = type;
    }

    auto ref get(Type)() if (staticIndexOf!(Type, Types) != -1)
    {
        return getID!(staticIndexOf!(Type, Types));
    }

    auto ref set(Type)(Type type) if (staticIndexOf!(Type, Types) != -1)
    {
        return setID!(staticIndexOf!(Type, Types))(type);
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
}
