#define EXTENSION_NAME GoPositionSetter
#define LIB_NAME "GoPositionSetter"
#define MODULE_NAME "go_position_setter"

#include <dmsdk/sdk.h>

#define USERDATA_METATABLE "POSITION_SETTER_USERDATA"

struct InstancePositionData {
    dmGameObject::HInstance rootInstance;
    dmVMath::Vector3 *position;
	// rotation quat
	dmVMath::Quat *rotation;

};

class PositionSetterUserdata {
  public:
    dmArray<InstancePositionData> instances;
    explicit PositionSetterUserdata();
    ~PositionSetterUserdata();
    void addInstance(dmGameObject::HInstance rootInstance, dmVMath::Vector3 *position, dmVMath::Quat *rotation);
    void update();
    void removeInstance(dmGameObject::HInstance rootInstance);
};

PositionSetterUserdata::PositionSetterUserdata() {
}

PositionSetterUserdata::~PositionSetterUserdata() {
}

void PositionSetterUserdata::addInstance(dmGameObject::HInstance rootInstance, dmVMath::Vector3 *position, dmVMath::Quat *rotation) {
    InstancePositionData instanceVector;
    instanceVector.rootInstance = rootInstance;
    instanceVector.position = position;
	instanceVector.rotation = rotation;
    if (instances.Full()) {
        instances.OffsetCapacity(32);
    }
    instances.Push(instanceVector);
}

void PositionSetterUserdata::update() {
    for (int i = 0; i < instances.Size(); ++i) {
        InstancePositionData instancePositionData = instances[i];
        dmGameObject::SetPosition(instancePositionData.rootInstance, dmVMath::Point3(*instancePositionData.position));
		dmGameObject::SetRotation(instancePositionData.rootInstance, *instancePositionData.rotation);
    }
}

void PositionSetterUserdata::removeInstance(dmGameObject::HInstance rootInstance) {
    for (int i = 0; i < instances.Size(); ++i) {
        InstancePositionData instancePositionData = instances[i];
        if (instancePositionData.rootInstance == rootInstance) {
            instances.EraseSwap(i);
            return;
        }
    }
}

static PositionSetterUserdata *PositionSetterUserdataCheck(lua_State *L, int index) {
    return *(PositionSetterUserdata **)luaL_checkudata(L, index, USERDATA_METATABLE);
}

static int LuaPositionSetterUserdataAddInstance(lua_State *L) {
    PositionSetterUserdata *userdata = PositionSetterUserdataCheck(L, 1);
    dmGameObject::HInstance rootInstance = dmScript::CheckGOInstance(L, 2);
    dmVMath::Vector3 *position = dmScript::CheckVector3(L, 3);
	dmVMath::Quat *rotation = dmScript::CheckQuat(L, 4);
    userdata->addInstance(rootInstance, position, rotation);
    return 0;
}

static int LuaPositionSetterUserdataUpdate(lua_State *L) {
    PositionSetterUserdata *userdata = PositionSetterUserdataCheck(L, 1);
    userdata->update();
    return 0;
}

static int LuaPositionSetterUserdataRemoveInstance(lua_State *L) {
    PositionSetterUserdata *userdata = PositionSetterUserdataCheck(L, 1);
    dmGameObject::HInstance rootInstance = dmScript::CheckGOInstance(L, 2);
    userdata->removeInstance(rootInstance);
    return 0;
}

static int LuaPositionSetterUserdataGC(lua_State *L) {
    PositionSetterUserdata *userdata = PositionSetterUserdataCheck(L, 1);
    delete userdata;
    return 0;
}

static const luaL_Reg LuaPositionSetterUserdataMethods[] = {
    {"__gc", LuaPositionSetterUserdataGC},
    {"add", LuaPositionSetterUserdataAddInstance},
    {"remove", LuaPositionSetterUserdataRemoveInstance},
    {"update", LuaPositionSetterUserdataUpdate},
    {0, 0}};

int NewPositionSetterUserdataLua(lua_State *L) {
    PositionSetterUserdata *userdata = new PositionSetterUserdata();
    PositionSetterUserdata **ud = (PositionSetterUserdata **)lua_newuserdata(L, sizeof(PositionSetterUserdata *));
    *ud = userdata;
    if (luaL_newmetatable(L, USERDATA_METATABLE)) {
        lua_pushvalue(L, -1);
        lua_setfield(L, -2, "__index");
        luaL_register(L, 0, LuaPositionSetterUserdataMethods);
    }
    lua_setmetatable(L, -2);
    return 1;
}

// Functions exposed to Lua
static const luaL_reg Module_methods[] = {
    {"new", NewPositionSetterUserdataLua},
    {0, 0}};

static void LuaInit(lua_State *L) {
    int top = lua_gettop(L);
    luaL_register(L, MODULE_NAME, Module_methods);
    lua_pop(L, 1);
    assert(top == lua_gettop(L));
}

static dmExtension::Result AppInitializeMyExtension(dmExtension::AppParams *params) { return dmExtension::RESULT_OK; }
static dmExtension::Result InitializeMyExtension(dmExtension::Params *params) {
    // Init Lua
    LuaInit(params->m_L);

    printf("Registered %s Extension\n", MODULE_NAME);
    return dmExtension::RESULT_OK;
}

static dmExtension::Result AppFinalizeMyExtension(dmExtension::AppParams *params) { return dmExtension::RESULT_OK; }

static dmExtension::Result FinalizeMyExtension(dmExtension::Params *params) { return dmExtension::RESULT_OK; }

DM_DECLARE_EXTENSION(EXTENSION_NAME, LIB_NAME, AppInitializeMyExtension, AppFinalizeMyExtension, InitializeMyExtension, 0, 0, FinalizeMyExtension)