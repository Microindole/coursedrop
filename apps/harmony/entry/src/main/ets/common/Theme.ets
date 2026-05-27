export class AppColors {
  static readonly BACKGROUND: string = '#F4F6F8';
  static readonly SURFACE: string = '#FFFFFF';
  static readonly SURFACE_MUTED: string = '#F0F2F4';
  static readonly PRIMARY: string = '#007DFF';
  static readonly PRIMARY_SELECTED: string = '#0A59F7';
  static readonly PRIMARY_SOFT: string = '#F0F6FF';
  static readonly TEXT: string = '#182431';
  static readonly TEXT_SECONDARY: string = '#7C8894';
  static readonly MUTED: string = '#A4AEB9';
  static readonly BORDER: string = '#08000000';
  static readonly BORDER_STRONG: string = '#1F182431';
  static readonly SUCCESS: string = '#10B981';
  static readonly SUCCESS_SOFT: string = '#ECFDF5';
  static readonly WARNING: string = '#F59E0B';
  static readonly WARNING_SOFT: string = '#FEF3C7';
  static readonly DANGER: string = '#EF4444';
  static readonly TAB_NORMAL: string = '#888D94';

  // 各内容类型的精细配色
  static readonly TONE_FILE: string = '#007DFF';
  static readonly TONE_FILE_BG: string = '#EDF5FF';
  static readonly TONE_IMAGE: string = '#FA2A2D';
  static readonly TONE_IMAGE_BG: string = '#FFF0F0';
  static readonly TONE_TEXT: string = '#F59E0B';
  static readonly TONE_TEXT_BG: string = '#FFFBEB';
  static readonly TONE_LINK: string = '#10B981';
  static readonly TONE_LINK_BG: string = '#ECFDF5';
}

export interface ShadowType {
  radius: number;
  color: string;
  offsetX: number;
  offsetY: number;
}

export class AppShadows {
  static readonly CARD: ShadowType = {
    radius: 12,
    color: '#08000000',
    offsetX: 0,
    offsetY: 4
  };
  static readonly FLOATING: ShadowType = {
    radius: 20,
    color: '#12000000',
    offsetX: 0,
    offsetY: 8
  };
}

export class AppSpacing {
  static readonly XS: number = 4;
  static readonly SM: number = 8;
  static readonly MD: number = 12;
  static readonly LG: number = 16;
  static readonly XL: number = 24;
  static readonly XXL: number = 32;
  static readonly PAGE_HORIZONTAL: number = 12;
  static readonly PAGE_TOP: number = 48;
}

export class AppRadius {
  static readonly SM: number = 8;
  static readonly MD: number = 12;
  static readonly LG: number = 16;
  static readonly XL: number = 24;
}

export class AppTypography {
  static readonly DISPLAY: number = 26;
  static readonly TITLE: number = 18;
  static readonly SUBTITLE: number = 16;
  static readonly BODY: number = 16;
  static readonly BODY_SMALL: number = 14;
  static readonly CAPTION: number = 12;
  static readonly TAB: number = 10;
}

export class AppSize {
  static readonly BUTTON_HEIGHT: number = 40;
  static readonly INPUT_HEIGHT: number = 45;
  static readonly LIST_ROW_HEIGHT: number = 48;
  static readonly TAB_BAR_HEIGHT: number = 56;
  static readonly ICON_MD: number = 24;
  static readonly ICON_LG: number = 40;
}
