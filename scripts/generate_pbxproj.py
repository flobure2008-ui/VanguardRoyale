import os

files = [
    ('App/VanguardRoyaleApp.swift', 'App', 'VanguardRoyaleApp.swift', False),
    ('App/Info.plist', 'App', 'Info.plist', False),
    ('State/BattleState.swift', 'State', 'BattleState.swift', False),
    ('State/KillfeedManager.swift', 'State', 'KillfeedManager.swift', False),
    ('Engine3D/SoundFXEngine.swift', 'Engine3D', 'SoundFXEngine.swift', False),
    ('Engine3D/TerrainBuilder.swift', 'Engine3D', 'TerrainBuilder.swift', False),
    ('Engine3D/StormSystem.swift', 'Engine3D', 'StormSystem.swift', False),
    ('Engine3D/WeaponSystem.swift', 'Engine3D', 'WeaponSystem.swift', False),
    ('Engine3D/PlayerCharacterNode.swift', 'Engine3D', 'PlayerCharacterNode.swift', False),
    ('Engine3D/BotAINode.swift', 'Engine3D', 'BotAINode.swift', False),
    ('Engine3D/LootItemNode.swift', 'Engine3D', 'LootItemNode.swift', False),
    ('Engine3D/BuildingSystem.swift', 'Engine3D', 'BuildingSystem.swift', False),
    ('Engine3D/BattleRoyaleScene.swift', 'Engine3D', 'BattleRoyaleScene.swift', False),
    ('Engine3D/Game3DViewController.swift', 'Engine3D', 'Game3DViewController.swift', False),
    ('UI/HUD3DView.swift', 'UI', 'HUD3DView.swift', False),
    ('UI/VictoryRoyaleView.swift', 'UI', 'VictoryRoyaleView.swift', False),
    ('UI/DefeatView.swift', 'UI', 'DefeatView.swift', False),
    ('Assets.xcassets', '', 'Assets.xcassets', True),
]

def make_id(prefix, name):
    h = '%08X%08X%08X' % (abs(hash(prefix)) % 0xFFFFFFFF, abs(hash(name)) % 0xFFFFFFFF, (abs(hash(prefix + name)) + 12345) % 0xFFFFFFFF)
    return h[:24]

proj_id = 'B10000000000000000000001'
target_id = 'B10000000000000000000002'
sources_phase_id = 'B10000000000000000000003'
frameworks_phase_id = 'B10000000000000000000004'
resources_phase_id = 'B10000000000000000000005'
main_group_id = 'B10000000000000000000006'
products_group_id = 'B10000000000000000000007'
product_ref_id = 'B10000000000000000000008'

proj_config_list_id = 'B10000000000000000000009'
target_config_list_id = 'B10000000000000000000010'
proj_debug_cfg_id = 'B10000000000000000000011'
proj_release_cfg_id = 'B10000000000000000000012'
target_debug_cfg_id = 'B10000000000000000000013'
target_release_cfg_id = 'B10000000000000000000014'

group_ids = {
    '': 'B10000000000000000000020',
    'App': 'B10000000000000000000021',
    'Engine3D': 'B10000000000000000000022',
    'State': 'B10000000000000000000023',
    'UI': 'B10000000000000000000024',
}

file_refs = {}
build_files = {}

for rel_path, grp, fname, is_res in files:
    fid = make_id('FILEREF', rel_path)
    file_refs[rel_path] = fid
    if fname != 'Info.plist':
        bid = make_id('BUILDFILE', rel_path)
        build_files[rel_path] = bid

pbx = []
pbx.append('// !$*UTF8*$!')
pbx.append('{')
pbx.append('\tarchiveVersion = 1;')
pbx.append('\tclasses = {')
pbx.append('\t};')
pbx.append('\tobjectVersion = 56;')
pbx.append('\tobjects = {')

# PBXBuildFile
pbx.append('\n/* Begin PBXBuildFile section */')
for rel_path, grp, fname, is_res in files:
    if rel_path in build_files:
        bid = build_files[rel_path]
        fid = file_refs[rel_path]
        phase_label = 'Resources' if is_res else 'Sources'
        pbx.append(f'\t\t{bid} /* {fname} in {phase_label} */ = {{isa = PBXBuildFile; fileRef = {fid} /* {fname} */; }};')
pbx.append('/* End PBXBuildFile section */')

# PBXFileReference
pbx.append('\n/* Begin PBXFileReference section */')
pbx.append(f'\t\t{product_ref_id} /* VanguardRoyale.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = VanguardRoyale.app; sourceTree = BUILT_PRODUCTS_DIR; }};')
for rel_path, grp, fname, is_res in files:
    fid = file_refs[rel_path]
    if is_res:
        ftype = 'folder.assetcatalog'
    elif fname.endswith('.swift'):
        ftype = 'sourcecode.swift'
    elif fname.endswith('.plist'):
        ftype = 'text.plist.xml'
    else:
        ftype = 'text'
    pbx.append(f'\t\t{fid} /* {fname} */ = {{isa = PBXFileReference; lastKnownFileType = {ftype}; path = {fname}; sourceTree = "<group>"; }};')
pbx.append('/* End PBXFileReference section */')

# PBXFrameworksBuildPhase
pbx.append('\n/* Begin PBXFrameworksBuildPhase section */')
pbx.append(f'\t\t{frameworks_phase_id} /* Frameworks */ = {{')
pbx.append('\t\t\tisa = PBXFrameworksBuildPhase;')
pbx.append('\t\t\tbuildActionMask = 2147483647;')
pbx.append('\t\t\tfiles = (')
pbx.append('\t\t\t);')
pbx.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
pbx.append('\t\t};')
pbx.append('/* End PBXFrameworksBuildPhase section */')

# PBXGroup
pbx.append('\n/* Begin PBXGroup section */')
# Root Main Group
pbx.append(f'\t\t{main_group_id} = {{')
pbx.append('\t\t\tisa = PBXGroup;')
pbx.append('\t\t\tchildren = (')
pbx.append(f'\t\t\t\t{group_ids[""]} /* VanguardRoyale */,')
pbx.append(f'\t\t\t\t{products_group_id} /* Products */,')
pbx.append('\t\t\t);')
pbx.append('\t\t\tsourceTree = "<group>";')
pbx.append('\t\t};')

# Products Group
pbx.append(f'\t\t{products_group_id} /* Products */ = {{')
pbx.append('\t\t\tisa = PBXGroup;')
pbx.append('\t\t\tchildren = (')
pbx.append(f'\t\t\t\t{product_ref_id} /* VanguardRoyale.app */,')
pbx.append('\t\t\t);')
pbx.append('\t\t\tname = Products;')
pbx.append('\t\t\tsourceTree = "<group>";')
pbx.append('\t\t};')

# VanguardRoyale Group
pbx.append(f'\t\t{group_ids[""]} /* VanguardRoyale */ = {{')
pbx.append('\t\t\tisa = PBXGroup;')
pbx.append('\t\t\tchildren = (')
pbx.append(f'\t\t\t\t{group_ids["App"]} /* App */,')
pbx.append(f'\t\t\t\t{group_ids["Engine3D"]} /* Engine3D */,')
pbx.append(f'\t\t\t\t{group_ids["State"]} /* State */,')
pbx.append(f'\t\t\t\t{group_ids["UI"]} /* UI */,')
pbx.append(f'\t\t\t\t{file_refs["Assets.xcassets"]} /* Assets.xcassets */,')
pbx.append('\t\t\t);')
pbx.append('\t\t\tpath = VanguardRoyale;')
pbx.append('\t\t\tsourceTree = "<group>";')
pbx.append('\t\t};')

# Subgroups
for grp_name in ['App', 'Engine3D', 'State', 'UI']:
    gid = group_ids[grp_name]
    grp_files = [f for f in files if f[1] == grp_name]
    pbx.append(f'\t\t{gid} /* {grp_name} */ = {{')
    pbx.append('\t\t\tisa = PBXGroup;')
    pbx.append('\t\t\tchildren = (')
    for rel_path, grp, fname, is_res in grp_files:
        fid = file_refs[rel_path]
        pbx.append(f'\t\t\t\t{fid} /* {fname} */,')
    pbx.append('\t\t\t);')
    pbx.append(f'\t\t\tpath = {grp_name};')
    pbx.append('\t\t\tsourceTree = "<group>";')
    pbx.append('\t\t};')

pbx.append('/* End PBXGroup section */')

# PBXNativeTarget
pbx.append('\n/* Begin PBXNativeTarget section */')
pbx.append(f'\t\t{target_id} /* VanguardRoyale */ = {{')
pbx.append('\t\t\tisa = PBXNativeTarget;')
pbx.append(f'\t\t\tbuildConfigurationList = {target_config_list_id} /* Build configuration list for PBXNativeTarget "VanguardRoyale" */;')
pbx.append('\t\t\tbuildPhases = (')
pbx.append(f'\t\t\t\t{sources_phase_id} /* Sources */,')
pbx.append(f'\t\t\t\t{frameworks_phase_id} /* Frameworks */,')
pbx.append(f'\t\t\t\t{resources_phase_id} /* Resources */,')
pbx.append('\t\t\t);')
pbx.append('\t\t\tbuildRules = (')
pbx.append('\t\t\t);')
pbx.append('\t\t\tdependencies = (')
pbx.append('\t\t\t);')
pbx.append('\t\t\tname = VanguardRoyale;')
pbx.append('\t\t\tproductName = VanguardRoyale;')
pbx.append(f'\t\t\tproductReference = {product_ref_id} /* VanguardRoyale.app */;')
pbx.append('\t\t\tproductType = "com.apple.product-type.application";')
pbx.append('\t\t};')
pbx.append('/* End PBXNativeTarget section */')

# PBXProject
pbx.append('\n/* Begin PBXProject section */')
pbx.append(f'\t\t{proj_id} /* Project object */ = {{')
pbx.append('\t\t\tisa = PBXProject;')
pbx.append('\t\t\tattributes = {')
pbx.append('\t\t\t\tBuildIndependentTargetsInParallel = 1;')
pbx.append('\t\t\t\tLastSwiftUpdateCheck = 1500;')
pbx.append('\t\t\t\tLastUpgradeCheck = 1500;')
pbx.append('\t\t\t\tTargetAttributes = {')
pbx.append(f'\t\t\t\t\t{target_id} = {{')
pbx.append('\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;')
pbx.append('\t\t\t\t\t};')
pbx.append('\t\t\t\t};')
pbx.append('\t\t\t};')
pbx.append(f'\t\t\tbuildConfigurationList = {proj_config_list_id} /* Build configuration list for PBXProject "VanguardRoyale" */;')
pbx.append('\t\t\tcompatibilityVersion = "Xcode 14.0";')
pbx.append('\t\t\tdevelopmentRegion = en;')
pbx.append('\t\t\thasScannedForEncodings = 0;')
pbx.append('\t\t\tknownRegions = (')
pbx.append('\t\t\t\ten,')
pbx.append('\t\t\t\tBase,')
pbx.append('\t\t\t);')
pbx.append(f'\t\t\tmainGroup = {main_group_id};')
pbx.append(f'\t\t\tproductRefGroup = {products_group_id} /* Products */;')
pbx.append('\t\t\tprojectDirPath = "";')
pbx.append('\t\t\tprojectRoot = "";')
pbx.append('\t\t\ttargets = (')
pbx.append(f'\t\t\t\t{target_id} /* VanguardRoyale */,')
pbx.append('\t\t\t);')
pbx.append('\t\t};')
pbx.append('/* End PBXProject section */')

# PBXResourcesBuildPhase
pbx.append('\n/* Begin PBXResourcesBuildPhase section */')
pbx.append(f'\t\t{resources_phase_id} /* Resources */ = {{')
pbx.append('\t\t\tisa = PBXResourcesBuildPhase;')
pbx.append('\t\t\tbuildActionMask = 2147483647;')
pbx.append('\t\t\tfiles = (')
for rel_path, grp, fname, is_res in files:
    if is_res and rel_path in build_files:
        bid = build_files[rel_path]
        pbx.append(f'\t\t\t\t{bid} /* {fname} in Resources */,')
pbx.append('\t\t\t);')
pbx.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
pbx.append('\t\t};')
pbx.append('/* End PBXResourcesBuildPhase section */')

# PBXSourcesBuildPhase
pbx.append('\n/* Begin PBXSourcesBuildPhase section */')
pbx.append(f'\t\t{sources_phase_id} /* Sources */ = {{')
pbx.append('\t\t\tisa = PBXSourcesBuildPhase;')
pbx.append('\t\t\tbuildActionMask = 2147483647;')
pbx.append('\t\t\tfiles = (')
for rel_path, grp, fname, is_res in files:
    if not is_res and fname.endswith('.swift') and rel_path in build_files:
        bid = build_files[rel_path]
        pbx.append(f'\t\t\t\t{bid} /* {fname} in Sources */,')
pbx.append('\t\t\t);')
pbx.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
pbx.append('\t\t};')
pbx.append('/* End PBXSourcesBuildPhase section */')

# XCBuildConfiguration
pbx.append('\n/* Begin XCBuildConfiguration section */')
pbx.append(f'\t\t{proj_debug_cfg_id} /* Debug */ = {{')
pbx.append('\t\t\tisa = XCBuildConfiguration;')
pbx.append('\t\t\tbuildSettings = {')
pbx.append('\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
pbx.append('\t\t\t\tCLANG_ANALYZER_NONNULL = YES;')
pbx.append('\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";')
pbx.append('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
pbx.append('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
pbx.append('\t\t\t\tCOPY_PHASE_STRIP = NO;')
pbx.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;')
pbx.append('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
pbx.append('\t\t\t\tENABLE_TESTABILITY = YES;')
pbx.append('\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;')
pbx.append('\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;')
pbx.append('\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (')
pbx.append('\t\t\t\t\t"DEBUG=1",')
pbx.append('\t\t\t\t\t"$(inherited)",')
pbx.append('\t\t\t\t);')
pbx.append('\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;')
pbx.append('\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;')
pbx.append('\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;')
pbx.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;')
pbx.append('\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;')
pbx.append('\t\t\t\tMTL_FAST_MATH = YES;')
pbx.append('\t\t\t\tONLY_ACTIVE_ARCH = YES;')
pbx.append('\t\t\t\tSDKROOT = iphoneos;')
pbx.append('\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;')
pbx.append('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";')
pbx.append('\t\t\t};')
pbx.append('\t\t\tname = Debug;')
pbx.append('\t\t};')

pbx.append(f'\t\t{proj_release_cfg_id} /* Release */ = {{')
pbx.append('\t\t\tisa = XCBuildConfiguration;')
pbx.append('\t\t\tbuildSettings = {')
pbx.append('\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
pbx.append('\t\t\t\tCLANG_ANALYZER_NONNULL = YES;')
pbx.append('\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";')
pbx.append('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
pbx.append('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
pbx.append('\t\t\t\tCOPY_PHASE_STRIP = NO;')
pbx.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
pbx.append('\t\t\t\tENABLE_NS_ASSERTIONS = NO;')
pbx.append('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
pbx.append('\t\t\t\tGCC_OPTIMIZATION_LEVEL = s;')
pbx.append('\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;')
pbx.append('\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;')
pbx.append('\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;')
pbx.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;')
pbx.append('\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;')
pbx.append('\t\t\t\tMTL_FAST_MATH = YES;')
pbx.append('\t\t\t\tSDKROOT = iphoneos;')
pbx.append('\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;')
pbx.append('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";')
pbx.append('\t\t\t\tVALIDATE_PRODUCT = YES;')
pbx.append('\t\t\t};')
pbx.append('\t\t\tname = Release;')
pbx.append('\t\t};')

pbx.append(f'\t\t{target_debug_cfg_id} /* Debug */ = {{')
pbx.append('\t\t\tisa = XCBuildConfiguration;')
pbx.append('\t\t\tbuildSettings = {')
pbx.append('\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
pbx.append('\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
pbx.append('\t\t\t\tCODE_SIGN_STYLE = Automatic;')
pbx.append('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
pbx.append('\t\t\t\tENABLE_PREVIEWS = YES;')
pbx.append('\t\t\t\tGENERATE_INFOPLIST_FILE = NO;')
pbx.append('\t\t\t\tINFOPLIST_FILE = VanguardRoyale/App/Info.plist;')
pbx.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;')
pbx.append('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (')
pbx.append('\t\t\t\t\t"$(inherited)",')
pbx.append('\t\t\t\t\t"@executable_path/Frameworks",')
pbx.append('\t\t\t\t);')
pbx.append('\t\t\t\tMARKETING_VERSION = 1.0.0;')
pbx.append('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.vanguard.royale;')
pbx.append('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
pbx.append('\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
pbx.append('\t\t\t\tSWIFT_VERSION = 5.0;')
pbx.append('\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
pbx.append('\t\t\t};')
pbx.append('\t\t\tname = Debug;')
pbx.append('\t\t};')

pbx.append(f'\t\t{target_release_cfg_id} /* Release */ = {{')
pbx.append('\t\t\tisa = XCBuildConfiguration;')
pbx.append('\t\t\tbuildSettings = {')
pbx.append('\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
pbx.append('\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
pbx.append('\t\t\t\tCODE_SIGN_STYLE = Automatic;')
pbx.append('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
pbx.append('\t\t\t\tENABLE_PREVIEWS = YES;')
pbx.append('\t\t\t\tGENERATE_INFOPLIST_FILE = NO;')
pbx.append('\t\t\t\tINFOPLIST_FILE = VanguardRoyale/App/Info.plist;')
pbx.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;')
pbx.append('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (')
pbx.append('\t\t\t\t\t"$(inherited)",')
pbx.append('\t\t\t\t\t"@executable_path/Frameworks",')
pbx.append('\t\t\t\t);')
pbx.append('\t\t\t\tMARKETING_VERSION = 1.0.0;')
pbx.append('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.vanguard.royale;')
pbx.append('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
pbx.append('\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
pbx.append('\t\t\t\tSWIFT_VERSION = 5.0;')
pbx.append('\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
pbx.append('\t\t\t};')
pbx.append('\t\t\tname = Release;')
pbx.append('\t\t};')

pbx.append('/* End XCBuildConfiguration section */')

# XCConfigurationList
pbx.append('\n/* Begin XCConfigurationList section */')
pbx.append(f'\t\t{proj_config_list_id} /* Build configuration list for PBXProject "VanguardRoyale" */ = {{')
pbx.append('\t\t\tisa = XCConfigurationList;')
pbx.append('\t\t\tbuildConfigurations = (')
pbx.append(f'\t\t\t\t{proj_debug_cfg_id} /* Debug */,')
pbx.append(f'\t\t\t\t{proj_release_cfg_id} /* Release */,')
pbx.append('\t\t\t);')
pbx.append('\t\t\tdefaultConfigurationIsVisible = 0;')
pbx.append('\t\t\tdefaultConfigurationName = Release;')
pbx.append('\t\t};')

pbx.append(f'\t\t{target_config_list_id} /* Build configuration list for PBXNativeTarget "VanguardRoyale" */ = {{')
pbx.append('\t\t\tisa = XCConfigurationList;')
pbx.append('\t\t\tbuildConfigurations = (')
pbx.append(f'\t\t\t\t{target_debug_cfg_id} /* Debug */,')
pbx.append(f'\t\t\t\t{target_release_cfg_id} /* Release */,')
pbx.append('\t\t\t);')
pbx.append('\t\t\tdefaultConfigurationIsVisible = 0;')
pbx.append('\t\t\tdefaultConfigurationName = Release;')
pbx.append('\t\t};')
pbx.append('/* End XCConfigurationList section */')

pbx.append('\t};')
pbx.append(f'\trootObject = {proj_id} /* Project object */;')
pbx.append('}')

output_path = os.path.join(os.path.dirname(__file__), '..', 'VanguardRoyale.xcodeproj', 'project.pbxproj')
with open(output_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(pbx) + '\n')

print('Generated VanguardRoyale project.pbxproj successfully! Lines:', len(pbx))
