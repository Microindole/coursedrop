import {
    CdBanner,
    CdBottomSheet,
    CdDetailSheet,
    CdFileList,
    CdFilePickerPanel,
    CdProgressRow,
    CdScrollContainer,
    CdSectionHeader,
    CdShareCode,
    CdTopBar
} from '../components/index';
import { ExpireStatus, NetworkMode } from '../models/CommonTypes';
import { TransferTask } from '../models/TransferTask';
import { ShareViewModel } from '../viewmodels/ShareViewModel';

@Component
export default struct SharePage {
    private viewModel: ShareViewModel = new ShareViewModel();
    showBack: boolean = false;
    @State detailVisible: boolean = false;
    @State selectedName: string = '';
    @State revision: number = 0;

    private refreshView(): void {
        this.revision += 1;
    }

    private networkMode(mode: NetworkMode): 'lan' | 'relay' | 'e2ee' | 'offline' {
        if (mode === 'LAN') {
            return 'lan';
        }
        if (mode === 'E2EE') {
            return 'e2ee';
        }
        if (mode === 'OFFLINE') {
            return 'offline';
        }
        return 'relay';
    }

    private expireTone(status: ExpireStatus): 'active' | 'soon' | 'expired' {
        if (status === 'EXPIRING_SOON') {
            return 'soon';
        }
        if (status === 'EXPIRED') {
            return 'expired';
        }
        return 'active';
    }

    private taskDescription(task: TransferTask): string {
        if (task.errorMessage !== undefined && task.errorMessage.length > 0) {
            return task.errorMessage;
        }
        return `${task.direction} · ${task.networkMode}`;
    }

    private async createRelayShare(): Promise<void> {
        await this.viewModel.refreshShareCode();
        this.refreshView();
    }

    build() {
        Stack({ alignContent: Alignment.TopStart }) {
            CdScrollContainer() {
                Column() {
                    if (this.revision < 0) {
                        Blank()
                    }

                    CdTopBar({
                        title: '分享详情',
                        subtitle: this.viewModel.currentSession.title,
                        leadingText: this.showBack ? '返回' : '',
                        onLeadingTap: () => {}
                    })

                    CdShareCode({
                        code: this.viewModel.currentSession.code,
                        shareUrl: this.viewModel.currentSession.shareUrl,
                        expireText: this.viewModel.getExpireText(),
                        expireTone: this.expireTone(this.viewModel.currentSession.expireStatus),
                        networkMode: this.networkMode(this.viewModel.currentSession.networkMode),
                        onCopy: () => {
                            this.viewModel.copyShareLink();
                            this.refreshView();
                        },
                        onRefresh: () => {
                            this.createRelayShare();
                        },
                        onRevoke: () => {
                            this.viewModel.revokeShare();
                            this.refreshView();
                        }
                    })

                    CdBanner({
                        title: this.viewModel.lastActionText.length > 0 ? this.viewModel.lastActionText : '当前是空分享草稿',
                        description: `状态 ${this.viewModel.currentSession.status} · 内容 ${this.viewModel.currentSession.itemCount} 项`,
                        tone: 'info'
                    })

                    CdSectionHeader({ title: '传输任务' })

                    ForEach(this.viewModel.getTasks(), (task: TransferTask) => {
                        CdProgressRow({
                            title: task.id,
                            description: this.taskDescription(task),
                            progress: task.progress
                        })
                    }, (task: TransferTask) => task.id)

                    CdSectionHeader({ title: '分享内容' })

                    CdFileList({
                        source: 'transfer',
                        transferItems: this.viewModel.getItems(),
                        onTransferTap: (id: string) => {
                            this.selectedName = this.viewModel.getItemName(id);
                            this.detailVisible = true;
                        }
                    })

                    CdFilePickerPanel({
                        onPickFile: () => {
                            this.viewModel.addLocalItem('FILE');
                            this.refreshView();
                        },
                        onPickImage: () => {
                            this.viewModel.addLocalItem('IMAGE');
                            this.refreshView();
                        },
                        onSendText: () => {
                            this.viewModel.addLocalItem('TEXT');
                            this.refreshView();
                        },
                        onSendLink: () => {
                            this.viewModel.addLocalItem('LINK');
                            this.refreshView();
                        }
                    })
                }
                .width('100%')
            }

            CdBottomSheet({ visible: $detailVisible }) {
                CdDetailSheet({
                    title: this.selectedName,
                    sizeText: 'local indexed item',
                    typeText: 'CourseDrop item',
                    createdText: this.viewModel.currentSession.createdAt,
                    expireText: this.viewModel.getExpireText(),
                    expireTone: this.expireTone(this.viewModel.currentSession.expireStatus),
                    networkMode: this.networkMode(this.viewModel.currentSession.networkMode),
                    encrypted: this.viewModel.currentSession.encrypted
                })
            }
        }
        .width('100%')
        .height('100%')
    }
}
