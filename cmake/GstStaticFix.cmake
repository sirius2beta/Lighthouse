# 2. 強制尋找失蹤的零件
find_library(REAL_LIB_JPEG      NAMES jpeg          PATHS ${GSTREAMER_LIB_PATH} NO_DEFAULT_PATH)
find_library(REAL_LIB_GRAPHENE  NAMES graphene-1.0  PATHS ${GSTREAMER_LIB_PATH} NO_DEFAULT_PATH)
find_library(REAL_LIB_PNG
    NAMES png png16 libpng libpng16
    PATHS ${GSTREAMER_LIB_PATH}
    NO_DEFAULT_PATH
)
find_library(REAL_LIB_CONTROLLER NAMES gstcontroller-1.0 PATHS ${GSTREAMER_LIB_PATH} NO_DEFAULT_PATH)

# 3. 把它們塞進連結清單
target_link_libraries(${CMAKE_PROJECT_NAME}
    PRIVATE
    ${REAL_LIB_JPEG}
    ${REAL_LIB_PNG}        # 解決這次噴出的 png_ 錯誤
    ${REAL_LIB_GRAPHENE}
    ${REAL_LIB_CONTROLLER}
    # 如果還有噴其他的 undefined symbol，就在這裡繼續補
)
