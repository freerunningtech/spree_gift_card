require 'spec_helper'

describe Spree::Admin::GiftCardsController do
  stub_authorization!
  let!(:user) { create(:user) }
  let(:gc_variant) { create(:master_variant) }
  let(:gc_params) { attributes_for(:gift_card).merge(variant_id: gc_variant.to_param) }

  describe "POST create" do
    context "when restricting the user" do
      let(:user) { create(:user) }
      subject { post :create, gift_card: gc_params, restrict_user: "1", use_route: :spree }

      before do
        gc_params.merge!(email: user_email)
      end

      context "when the user is found" do
        let(:user_email) { user.email }

        it { should redirect_to(spree.admin_gift_cards_path) }

        it "creates the gift card accordingly" do
          subject
          expect(Spree::GiftCard.last.user).to eql(user)
        end
      end

      context "when the user is not found" do
        let(:user_email) { "avc@sdfs.ca" }

        it { should render_template(:new) }

        it "does not create a gift card" do
          expect{subject}.to_not change{Spree::GiftCard.count}
        end
      end
    end

    context "when not restricting the user" do
      subject { post :create, gift_card: gc_params, use_route: :spree }

      context "when the object saves" do
        describe "response" do
          it { should redirect_to(spree.admin_gift_cards_path) }
        end

        describe "gift card" do
          before do
            post :create, gift_card: gc_params, use_route: :spree
          end

          subject { Spree::GiftCard.last }

          it { should be }
          its(:name) { should eql(gc_params[:name]) }
        end
      end

      context "when the object doesn't save" do
        before do
          # Make it invalid
          gc_params.delete(:name)
        end

        describe "response" do
          it { should render_template(:new) }
        end

        describe "gift card" do
          before do
            post :create, gift_card: gc_params, use_route: :spree
          end

          subject { Spree::GiftCard.last }

          it { should be_nil }
        end
      end
    end
  end

  describe "PUT update" do
    let(:gc) { create(:gift_card) }

    context "when restricting the user" do
      let(:user) { create(:user) }
      subject { put :update, id: gc.id, gift_card: gc_params, restrict_user: "1", use_route: :spree }

      before do
        gc_params.merge!(email: user_email)
      end

      context "when the user is found" do
        let(:user_email) { user.email }

        it { should redirect_to(spree.admin_gift_cards_path) }

        it "updates the gift card accordingly" do
          subject
          expect(gc.reload.user).to eql(user)
        end
      end

      context "when the user is not found" do
        let(:user_email) { "avc@sdfs.ca" }

        it { should render_template(:edit) }

        it "does not update the gift card" do
          expect(gc).to_not receive(:save)
          subject
        end
      end
    end

    context "when not restricting the user" do
      subject { put :update, id: gc.id, gift_card: gc_params, use_route: :spree }
      before do
        gc_params.merge!(email: "test@test.ca")
      end

      context "when the object saves" do
        describe "response" do
          it { should redirect_to(spree.admin_gift_cards_path) }
        end

        describe "gift card" do
          before do
            put :update, id: gc.id, gift_card: gc_params, use_route: :spree
          end

          subject { gc.reload }
          its(:email) { should eql("test@test.ca") }
        end
      end

      context "when the object doesn't save" do
        before do
          # Make it invalid
          gc_params.merge!(name: nil)
        end

        describe "response" do
          it { should render_template(:edit) }
        end

        describe "gift card" do
          before do
            put :update, id: gc.id, gift_card: gc_params, use_route: :spree
          end

          it "does not change the gift card" do
            expect(gc.reload.email).to_not eql("test@test.ca")
          end
        end
      end
    end
  end
end