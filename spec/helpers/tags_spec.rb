require 'spec_helper'
include Kaminari::Helpers

describe 'Kaminari::Helpers' do
  describe '#page_url_for' do
    before do
      helper.params.merge!(:controller => 'users', :action => 'index')
      Kaminari.config.skip_first_page_param = true
    end

    context 'for first page' do
      subject { Tag.new(helper).page_url_for(1) }
      it { should_not match(/page=1/) }

      context 'when skip_first_page_param is set to false' do
        before { Kaminari.config.skip_first_page_param = false }
        it { should match(/page=1/) }
        after { Kaminari.config.skip_first_page_param = true }
      end
    end

    context 'for other pages' do
      subject { Tag.new(helper).page_url_for(2) }
      it { should match(/page=2/) }
    end
  end

  describe 'Paginator' do
    describe 'Paginator::PageProxy' do
      describe '#current?' do
        context 'current_page == page' do
          subject { Paginator::PageProxy.new({:current_page => 26}, 26, nil) }
          its(:current?) { should be_true }
        end
        context 'current_page != page' do
          subject { Paginator::PageProxy.new({:current_page => 13}, 26, nil) }
          its(:current?) { should_not be_true }
        end
      end

      describe '#first?' do
        context 'page == 1' do
          subject { Paginator::PageProxy.new({:current_page => 26}, 1, nil) }
          its(:first?) { should be_true }
        end
        context 'page != 1' do
          subject { Paginator::PageProxy.new({:current_page => 13}, 2, nil) }
          its(:first?) { should_not be_true }
        end
      end

      describe '#last?' do
        context 'current_page == page' do
          subject { Paginator::PageProxy.new({:total_pages => 39}, 39, nil) }
          its(:last?) { should be_true }
        end
        context 'current_page != page' do
          subject { Paginator::PageProxy.new({:total_pages => 39}, 38, nil) }
          its(:last?) { should_not be_true }
        end
      end

      describe '#next?' do
        context 'page == current_page + 1' do
          subject { Paginator::PageProxy.new({:current_page => 52}, 53, nil) }
          its(:next?) { should be_true }
        end
        context 'page != current_page + 1' do
          subject { Paginator::PageProxy.new({:current_page => 52}, 77, nil) }
          its(:next?) { should_not be_true }
        end
      end

      describe '#prev?' do
        context 'page == current_page - 1' do
          subject { Paginator::PageProxy.new({:current_page => 77}, 76, nil) }
          its(:prev?) { should be_true }
        end
        context 'page != current_page + 1' do
          subject { Paginator::PageProxy.new({:current_page => 77}, 80, nil) }
          its(:prev?) { should_not be_true }
        end
      end

      describe '#left_outer?' do
        context 'current_page == left' do
          subject { Paginator::PageProxy.new({:left => 3}, 3, nil) }
          its(:left_outer?) { should be_true }
        end
        context 'current_page == left + 1' do
          subject { Paginator::PageProxy.new({:left => 3}, 4, nil) }
          its(:left_outer?) { should_not be_true }
        end
        context 'current_page == left + 2' do
          subject { Paginator::PageProxy.new({:left => 3}, 5, nil) }
          its(:left_outer?) { should_not be_true }
        end
      end

      describe '#right_outer?' do
        context 'total_pages - page > right' do
          subject { Paginator::PageProxy.new({:total_pages => 10, :right => 3}, 6, nil) }
          its(:right_outer?) { should_not be_true }
        end
        context 'total_pages - page == right' do
          subject { Paginator::PageProxy.new({:total_pages => 10, :right => 3}, 7, nil) }
          its(:right_outer?) { should_not be_true }
        end
        context 'total_pages - page < right' do
          subject { Paginator::PageProxy.new({:total_pages => 10, :right => 3}, 8, nil) }
          its(:right_outer?) { should be_true }
        end
      end

      describe '#inside_window?' do
        context 'page > current_page' do
          context 'page - current_page > window' do
            subject { Paginator::PageProxy.new({:current_page => 4, :window => 5}, 10, nil) }
            its(:inside_window?) { should_not be_true }
          end
          context 'page - current_page == window' do
            subject { Paginator::PageProxy.new({:current_page => 4, :window => 6}, 10, nil) }
            its(:inside_window?) { should be_true }
          end
          context 'page - current_page < window' do
            subject { Paginator::PageProxy.new({:current_page => 4, :window => 7}, 10, nil) }
            its(:inside_window?) { should be_true }
          end
        end
        context 'current_page > page' do
          context 'current_page - page > window' do
            subject { Paginator::PageProxy.new({:current_page => 15, :window => 4}, 10, nil) }
            its(:inside_window?) { should_not be_true }
          end
          context 'current_page - page == window' do
            subject { Paginator::PageProxy.new({:current_page => 15, :window => 5}, 10, nil) }
            its(:inside_window?) { should be_true }
          end
          context 'current_page - page < window' do
            subject { Paginator::PageProxy.new({:current_page => 15, :window => 6}, 10, nil) }
            its(:inside_window?) { should be_true }
          end
        end
      end
      describe '#was_truncated?' do
        before do
          stub(@template = Object.new) do
            options { {} }
            params { {} }
          end
        end
        context 'last.is_a? Gap' do
          subject { Paginator::PageProxy.new({}, 10, Gap.new(@template)) }
          its(:was_truncated?) { should be_true }
        end
        context 'last.is not a Gap' do
          subject { Paginator::PageProxy.new({}, 10, Page.new(@template)) }
          its(:was_truncated?) { should_not be_true }
        end
      end
    end
  end
end
